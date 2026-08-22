package com.commerce.support;

import java.util.HashMap;
import java.util.List;

import com.commerce.ec.od.order.service.OrderService;

/**
 * 주문 파라미터 만들기
 *
 * OrderController.saveOrder 가 화면 값으로 만들어 서비스에 넘기는 맵과 같은 것을 만든다.
 * 서비스 계층만 띄운 테스트에는 컨트롤러가 없어서 그 계산을 여기서 되풀이한다.
 * 되풀이하는 이유는 금액 계산이 컨트롤러에 있기 때문이고,
 * 그 자리가 맞는지는 지금 다루지 않는다. 옮기면 이 클래스도 같이 줄어든다.
 *
 * 주문번호는 밖에서 넣는다. OrderServiceImpl 이 만드는 번호는
 * 날짜 + 4자리 난수라 같은 실행 안에서 충돌할 수 있고,
 * 그 충돌은 여기서 보려는 것과 다른 부채다.
 */
public class OrderFixture {

	/** 시드 데이터의 정상 회원 */
	public static final String MBR_NO = "M000000001";

	private final OrderService orderService;

	public OrderFixture(OrderService orderService) {
		this.orderService = orderService;
	}

	/**
	 * 상품 한 건짜리 바로구매 주문
	 *
	 * @param payTpCd 10:무통장입금, 20:카드결제(PG 승인을 탄다)
	 */
	public HashMap<String, Object> singleProductOrder(String ordNo, String payTpCd,
													  String prdCd, int ordQty) throws Exception {
		HashMap<String, Object> param = new HashMap<String, Object>();
		param.put("ordNo", ordNo);
		param.put("mbrNo", MBR_NO);
		param.put("payTpCd", payTpCd);
		param.put("prdCd", prdCd);
		param.put("ordQty", String.valueOf(ordQty));   // 화면은 문자열로 넘긴다
		param.put("fromCart", "N");

		List<HashMap<String, Object>> orderPrdList = orderService.selectOrderPrdList(param);
		if (orderPrdList == null || orderPrdList.isEmpty()) {
			throw new IllegalStateException("주문할 수 있는 상품이 아니다 : " + prdCd);
		}

		// 결제수단별 할인가 적용 - OrderController.saveOrder 와 같은 계산
		long payAmt = 0;
		for (int i = 0; i < orderPrdList.size(); i++) {
			HashMap<String, Object> prd = orderPrdList.get(i);

			long salePrc = toLong(prd.get("salePrc"));
			int qty = toInt(prd.get("ordQty"));
			long cardDiscPrc = toLong(prd.get("cardDiscPrc"));
			long cashDiscPrc = toLong(prd.get("cashDiscPrc"));

			long effectivePrc = salePrc;
			if ("20".equals(payTpCd) && cardDiscPrc > 0) {
				effectivePrc = cardDiscPrc;
			} else if ("10".equals(payTpCd) && cashDiscPrc > 0) {
				effectivePrc = cashDiscPrc;
			}

			prd.put("effectivePrc", effectivePrc);
			prd.put("discAmt", (salePrc - effectivePrc) * qty);
			prd.put("ordAmt", effectivePrc * qty);
			payAmt += effectivePrc * qty;
		}

		param.put("payAmt", payAmt);
		param.put("orderPrdList", orderPrdList);

		// 배송지 - 주문서 화면에서 넘어오는 값
		param.put("depositorNm", "김나라");
		param.put("reciverNm", "김나라");
		param.put("delvHpNo", "010-1234-5678");
		param.put("delvZipcode", "06134");
		param.put("delvBaseAddr", "서울특별시 강남구 테헤란로 123");
		param.put("delvDtlAddr", "4층 401호");
		param.put("delvMsg", "부재 시 경비실");

		return param;
	}

	private long toLong(Object val) {
		if (val == null) return 0L;
		if (val instanceof Number) return ((Number) val).longValue();
		try { return Long.parseLong(val.toString().trim()); } catch (NumberFormatException e) { return 0L; }
	}

	private int toInt(Object val) {
		if (val == null) return 0;
		if (val instanceof Number) return ((Number) val).intValue();
		try { return Integer.parseInt(val.toString().trim()); } catch (NumberFormatException e) { return 0; }
	}
}
