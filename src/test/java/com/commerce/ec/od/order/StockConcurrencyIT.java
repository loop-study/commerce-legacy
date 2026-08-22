package com.commerce.ec.od.order;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import javax.annotation.Resource;

import org.assertj.core.api.SoftAssertions;
import org.junit.Before;
import org.junit.Test;

import com.commerce.ec.od.order.service.OrderService;
import com.commerce.support.AbstractServiceIT;
import com.commerce.support.OrderFixture;

/**
 * 재고 차감 동시성
 *
 * repro/oversell.sh 가 HTTP 로 재현하던 것을 서비스 계층에서 다시 세운다.
 * 스크립트는 앱이 떠 있어야 돌고 결과를 눈으로 읽어야 한다.
 * 여기 옮겨두면 빌드가 매번 확인해준다.
 *
 * 무엇이 깨져 있나 (OrderServiceImpl.saveOrderTx:196-215)
 *
 *   int salePssbQty = orderMapper.selectPrdStockQty(dtlMap);   // ① 읽고
 *   if (salePssbQty > 0) {                                     // ② 판단하고
 *       orderMapper.updatePrdStockDecrease(dtlMap);            // ③ 뺀다
 *   }
 *
 *   UPDATE TB_PRD_MST SET STOCK_QTY = STOCK_QTY - ${ordQty}
 *   WHERE PRD_CD = #{prdCd}        -- 재고가 얼마든 그냥 뺀다
 *
 * ①과 ③ 사이에 다른 요청이 끼어들면 둘 다 "재고 있음"으로 판단하고,
 * 차감에는 조건이 없으므로 재고가 0 아래로 내려간다.
 * 0 이하가 되면 ②에서 걸러져 차감이 아예 멈춘다 —
 * 이 코드에서 0 은 "재고 미관리(무제한)"라는 뜻이기 때문이다.
 * 그래서 주문은 성공했는데 차감은 안 된 건이 생긴다.
 *
 * ※ 이 테스트는 지금 실패한다. 단언 네 개가 Phase 2 에서 만족시켜야 할 명세다.
 *   경합의 결과라 실행할 때마다 어느 단언이 걸리는지는 달라진다.
 *   스레드가 서로를 완전히 지나치면 차감은 20번 다 돌고 재고만 음수로 내려가고,
 *   줄을 서면 차감이 중간에 멈춰 주문 수량과 차감량이 어긋난다.
 *   어느 쪽이든 "재고보다 많이 팔렸다"는 첫 단언은 항상 걸린다.
 */
public class StockConcurrencyIT extends AbstractServiceIT {

	/** 시드 데이터의 재고 관리 상품 */
	private static final String PRD_CD = "P000000001";

	private static final int STOCK = 5;
	private static final int CONCURRENT_ORDERS = 20;

	@Resource(name = "orderService")
	private OrderService orderService;

	@Before
	public void 재고를_다시_세운다() {
		jdbc().update("DELETE FROM TB_ORD_DTL WHERE ORD_NO LIKE 'OTST%'");
		jdbc().update("DELETE FROM TB_ORD_MST WHERE ORD_NO LIKE 'OTST%'");
		jdbc().update("UPDATE TB_PRD_MST SET STOCK_QTY = ?, PRD_STAT_CD = '30' WHERE PRD_CD = ?",
				STOCK, PRD_CD);
	}

	@Test
	public void 재고_5개에_20건이_동시에_들어와도_5건까지만_팔린다() throws Exception {
		OrderFixture fixture = new OrderFixture(orderService);

		// 파라미터는 미리 다 만들어둔다.
		// 스레드 안에서 만들면 상품 조회가 경합 시점을 흩뜨린다.
		List<HashMap<String, Object>> orders = new ArrayList<HashMap<String, Object>>();
		for (int i = 0; i < CONCURRENT_ORDERS; i++) {
			orders.add(fixture.singleProductOrder(String.format("OTST%03d", i), "10", PRD_CD, 1));
		}

		final CountDownLatch startGate = new CountDownLatch(1);
		final CountDownLatch finished = new CountDownLatch(CONCURRENT_ORDERS);
		final AtomicInteger succeeded = new AtomicInteger();

		ExecutorService pool = Executors.newFixedThreadPool(CONCURRENT_ORDERS);
		for (int i = 0; i < CONCURRENT_ORDERS; i++) {
			final HashMap<String, Object> param = orders.get(i);
			pool.execute(new Runnable() {
				@Override
				public void run() {
					try {
						startGate.await();
						HashMap<String, Object> rtn = orderService.saveOrderTx(param);
						if ("SUCCESS".equals(rtn.get("rtnCode"))) {
							succeeded.incrementAndGet();
						}
					} catch (Exception e) {
						// 실패한 주문은 성공으로 세지 않는다. 여기서 필요한 건 그것뿐이다.
					} finally {
						finished.countDown();
					}
				}
			});
		}

		startGate.countDown();
		finished.await(60, TimeUnit.SECONDS);
		pool.shutdown();

		int remainingStock = jdbc().queryForObject(
				"SELECT STOCK_QTY FROM TB_PRD_MST WHERE PRD_CD = ?", Integer.class, PRD_CD);
		int orderedQty = jdbc().queryForObject(
				"SELECT COALESCE(SUM(ORD_QTY), 0) FROM TB_ORD_DTL WHERE PRD_CD = ? AND ORD_NO LIKE 'OTST%'",
				Integer.class, PRD_CD);
		String prdStatCd = jdbc().queryForObject(
				"SELECT PRD_STAT_CD FROM TB_PRD_MST WHERE PRD_CD = ?", String.class, PRD_CD);

		SoftAssertions softly = new SoftAssertions();
		softly.assertThat(succeeded.get())
				.as("성공한 주문은 재고를 넘을 수 없다")
				.isLessThanOrEqualTo(STOCK);
		softly.assertThat(remainingStock)
				.as("재고는 음수가 될 수 없다")
				.isGreaterThanOrEqualTo(0);
		softly.assertThat(STOCK - remainingStock)
				.as("주문된 수량만큼 정확히 차감돼야 한다 (주문 %d건분)", orderedQty)
				.isEqualTo(orderedQty);
		softly.assertThat(prdStatCd)
				.as("재고가 바닥난 상품이 판매중(30)으로 남아 있으면 안 된다")
				.isEqualTo("40");
		softly.assertAll();
	}
}
