package com.commerce.ec.my.order;

import static com.github.tomakehurst.wiremock.client.WireMock.aResponse;
import static com.github.tomakehurst.wiremock.client.WireMock.findAll;
import static com.github.tomakehurst.wiremock.client.WireMock.post;
import static com.github.tomakehurst.wiremock.client.WireMock.postRequestedFor;
import static com.github.tomakehurst.wiremock.client.WireMock.stubFor;
import static com.github.tomakehurst.wiremock.client.WireMock.urlEqualTo;
import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;

import javax.annotation.Resource;

import org.assertj.core.api.SoftAssertions;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import com.commerce.admin.od.order.service.OrdMngService;
import com.commerce.ec.my.order.service.MyOrderService;
import com.commerce.ec.od.order.service.OrderService;
import com.commerce.support.AbstractServiceIT;
import com.commerce.support.OrderFixture;
import com.github.tomakehurst.wiremock.client.ResponseDefinitionBuilder;
import com.github.tomakehurst.wiremock.junit.WireMockRule;

/**
 * 카드주문 취소와 PG 승인 취소
 *
 * 카드로 결제한 주문을 취소하면 주문 상태는 90(주문취소)이 되고 재고도 돌아온다.
 * 그런데 PG 에 걸어둔 승인은 그대로 남는다.
 * MyOrderServiceImpl 과 OrdMngServiceImpl 어느 쪽에도 PgApiUtil 이 주입돼 있지 않다.
 * 취소를 아는 코드가 PG 를 부를 방법 자체가 없다.
 *
 * 대조군은 OrderServiceImpl.saveOrderTx:233-245 다.
 * 주문 저장이 실패했을 때는 승인을 되돌린다. 취소 경로에만 그것이 없다.
 *
 * 화면은 승인번호를 그대로 보여주면서 "주문이 취소되었습니다" 라고 알린다.
 * 돈은 고객 카드에 남아 있고, 그 사실을 아무 데서도 알 수 없다.
 *
 * PG 는 WireMock 으로 세운다. PgApiUtil 은 URL 을 MessageSource 에서 읽으므로
 * -D 로는 못 덮는다. 테스트 클래스패스의 message-common.properties 사본이
 * pg.api.* 만 이 포트로 바꿔둔 것을 쓴다.
 *
 * ※ 이 테스트는 지금 두 개 다 실패한다.
 */
public class OrderCancelIT extends AbstractServiceIT {

	/** message-common.properties 테스트 사본의 pg.api.* 와 같은 포트여야 한다 */
	private static final int PG_PORT = 18080;

	private static final String APPROVE_PATH = "/mock/pg/approve.do";
	private static final String CANCEL_PATH = "/mock/pg/cancel.do";

	private static final String PRD_CD = "P000000002";
	private static final String PG_APRV_NO = "PG20260822000001";

	@Rule
	public WireMockRule pgServer = new WireMockRule(PG_PORT);

	@Resource(name = "orderService")
	private OrderService orderService;

	@Resource(name = "myOrderService")
	private MyOrderService myOrderService;

	@Resource(name = "ordMngService")
	private OrdMngService ordMngService;

	@Before
	public void PG를_세우고_주문을_지운다() {
		stubFor(post(urlEqualTo(APPROVE_PATH)).willReturn(json(
				"{\"resultCd\":\"0000\",\"resultMsg\":\"승인완료\",\"aprvNo\":\"" + PG_APRV_NO + "\"}")));
		stubFor(post(urlEqualTo(CANCEL_PATH)).willReturn(json(
				"{\"resultCd\":\"0000\",\"resultMsg\":\"취소완료\"}")));

		jdbc().update("DELETE FROM TB_ORD_DTL WHERE ORD_NO LIKE 'OCAN%'");
		jdbc().update("DELETE FROM TB_ORD_MST WHERE ORD_NO LIKE 'OCAN%'");
		jdbc().update("UPDATE TB_PRD_MST SET STOCK_QTY = 100, PRD_STAT_CD = '30' WHERE PRD_CD = ?", PRD_CD);
	}

	@Test
	public void 회원이_카드주문을_취소하면_PG_승인도_취소된다() throws Exception {
		String ordNo = 카드주문을_만든다("OCAN001");

		HashMap<String, Object> param = new HashMap<String, Object>();
		param.put("ordNo", ordNo);
		param.put("mbrNo", OrderFixture.MBR_NO);

		HashMap<String, Object> rtn = myOrderService.updateMyOrderCancelTx(param);

		취소됐는지_확인한다(rtn.get("rtnCode"), ordNo);
	}

	@Test
	public void 관리자가_카드주문을_취소하면_PG_승인도_취소된다() throws Exception {
		String ordNo = 카드주문을_만든다("OCAN002");

		HashMap<String, Object> param = new HashMap<String, Object>();
		param.put("ordNo", ordNo);
		param.put("ordStatCd", "90");

		HashMap<String, Object> rtn = ordMngService.updateOrdStatTx(param);

		취소됐는지_확인한다(rtn.get("rtnCode"), ordNo);
	}

	/** PG 승인을 받은 카드주문을 하나 만든다. */
	private String 카드주문을_만든다(String ordNo) throws Exception {
		HashMap<String, Object> param =
				new OrderFixture(orderService).singleProductOrder(ordNo, "20", PRD_CD, 1);

		HashMap<String, Object> rtn = orderService.saveOrderTx(param);

		assertThat(rtn.get("rtnCode")).as("주문이 만들어져야 취소를 볼 수 있다").isEqualTo("SUCCESS");
		assertThat(findAll(postRequestedFor(urlEqualTo(APPROVE_PATH))))
				.as("카드주문이므로 PG 승인을 한 번 탄다").hasSize(1);

		return ordNo;
	}

	private void 취소됐는지_확인한다(Object rtnCode, String ordNo) {
		String ordStatCd = jdbc().queryForObject(
				"SELECT ORD_STAT_CD FROM TB_ORD_MST WHERE ORD_NO = ?", String.class, ordNo);
		String pgAprvNo = jdbc().queryForObject(
				"SELECT PG_APRV_NO FROM TB_ORD_MST WHERE ORD_NO = ?", String.class, ordNo);
		int cancelCalls = findAll(postRequestedFor(urlEqualTo(CANCEL_PATH))).size();

		SoftAssertions softly = new SoftAssertions();
		softly.assertThat(rtnCode).as("취소는 성공으로 보고된다").isEqualTo("SUCCESS");
		softly.assertThat(ordStatCd).as("주문 상태는 취소(90)가 된다").isEqualTo("90");
		softly.assertThat(cancelCalls)
				.as("취소된 주문의 PG 승인번호가 %s 인데 취소 요청은 %d 번 나갔다", pgAprvNo, cancelCalls)
				.isEqualTo(1);
		softly.assertAll();
	}

	private ResponseDefinitionBuilder json(String body) {
		return aResponse()
				.withStatus(200)
				.withHeader("Content-Type", "application/json;charset=UTF-8")
				.withBody(body);
	}
}
