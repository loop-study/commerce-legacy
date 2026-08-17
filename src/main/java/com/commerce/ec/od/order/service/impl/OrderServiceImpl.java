package com.commerce.ec.od.order.service.impl;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.commerce.ec.cmmn.utils.NumberUtil;
import com.commerce.ec.cmmn.utils.PgApiUtil;
import com.commerce.ec.od.cart.service.impl.CartMapper;
import com.commerce.ec.od.order.service.OrderService;

@Service("orderService")
public class OrderServiceImpl implements OrderService {

	private static final Logger logger = LoggerFactory.getLogger(OrderServiceImpl.class);

	@Resource(name = "orderMapper")
	private OrderMapper orderMapper;

	@Resource(name = "cartMapper")
	private CartMapper cartMapper;

	@Resource
	private PgApiUtil pgApiUtil;

	@Override
	public List<HashMap<String, Object>> selectOrderPrdList(HashMap<String, Object> paramMap) throws Exception {
		String fromCart = (String) paramMap.get("fromCart");
		if ("Y".equals(fromCart)) {
			// 장바구니 선택주문 : "1,2,3" 형태를 IN 조건용 목록으로 변환
			String cartNoList = (String) paramMap.get("cartNoList");
			if (cartNoList != null && !"".equals(cartNoList.trim())) {
				List<String> cartNoArr = new java.util.ArrayList<String>();
				String[] cartNos = cartNoList.split(",");
				for (int i = 0; i < cartNos.length; i++) {
					String cartNo = cartNos[i].trim();
					if (!"".equals(cartNo)) {
						cartNoArr.add(cartNo);
					}
				}
				paramMap.put("cartNoArr", cartNoArr);
			}
			return orderMapper.selectOrderPrdListFromCart(paramMap);
		} else {
			// 바로구매: 단건 상품 정보 조회
			HashMap<String, Object> prdInfo = orderMapper.selectOrderPrdInfo(paramMap);
			List<HashMap<String, Object>> list = new java.util.ArrayList<HashMap<String, Object>>();
			if (prdInfo != null) {
				list.add(prdInfo);
			}
			return list;
		}
	}

	@Override
	public HashMap<String, Object> selectMbrInfo(HashMap<String, Object> paramMap) throws Exception {
		return orderMapper.selectMbrInfo(paramMap);
	}

	/** 주문번호 생성: ORD + yyyyMMdd + 4자리 랜덤 */
	private String newOrdNo() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		return "ORD" + sdf.format(new Date()) + NumberUtil.randNumGenerate(4);
	}

	/**
	 * 결제 준비 단계에서 주문번호를 만들고 선택한 상품을 임시 주문에 담아둔다.
	 * 결제창을 거치는 동안 주문 내용을 서버에 남겨두기 위한 것이고,
	 * 결제가 확정되면 saveOrderTx 가 이 행을 지운다.
	 */
	@Override
	public String insertOrderTempTx(HashMap<String, Object> paramMap,
								  List<HashMap<String, Object>> orderPrdList) throws Exception {
		String ordNo = newOrdNo();

		// 상품코드와 수량만 담는다. 가격은 결제 시점에 다시 조회한다.
		List<HashMap<String, Object>> jsonList = new java.util.ArrayList<HashMap<String, Object>>();
		for (int i = 0; i < orderPrdList.size(); i++) {
			HashMap<String, Object> prd = orderPrdList.get(i);
			HashMap<String, Object> item = new HashMap<String, Object>();
			item.put("prdCd", prd.get("prdCd"));
			item.put("ordQty", toInt(prd.get("ordQty")));
			jsonList.add(item);
		}

		HashMap<String, Object> tempMap = new HashMap<String, Object>();
		tempMap.put("ordNo", ordNo);
		tempMap.put("mbrNo", paramMap.get("mbrNo"));
		tempMap.put("ordPrdJson", new ObjectMapper().writeValueAsString(jsonList));
		tempMap.put("fromCart", "Y".equals(paramMap.get("fromCart")) ? "Y" : "N");
		tempMap.put("cartNoList", paramMap.get("cartNoList"));
		orderMapper.insertOrderTemp(tempMap);

		return ordNo;
	}

	@Override
	public HashMap<String, Object> selectOrderTemp(HashMap<String, Object> paramMap) throws Exception {
		return orderMapper.selectOrderTemp(paramMap);
	}

	/**
	 * 임시 주문에 담아둔 상품코드/수량으로 주문 상품 목록을 다시 만든다.
	 * 가격은 화면에서 넘어온 값을 믿지 않고 여기서 조회한 값을 쓴다.
	 */
	@Override
	public List<HashMap<String, Object>> selectOrderPrdListByTemp(HashMap<String, Object> tempOrder) throws Exception {
		String ordPrdJson = (String) tempOrder.get("ordPrdJson");

		List<HashMap<String, Object>> items = new ObjectMapper().readValue(
				ordPrdJson, new TypeReference<List<HashMap<String, Object>>>() {});

		List<HashMap<String, Object>> list = new java.util.ArrayList<HashMap<String, Object>>();
		for (int i = 0; i < items.size(); i++) {
			HashMap<String, Object> item = items.get(i);

			HashMap<String, Object> prdParam = new HashMap<String, Object>();
			prdParam.put("prdCd", item.get("prdCd"));
			prdParam.put("ordQty", toInt(item.get("ordQty")));

			HashMap<String, Object> prdInfo = orderMapper.selectOrderPrdInfo(prdParam);
			if (prdInfo != null) {
				list.add(prdInfo);
			}
		}
		return list;
	}

	@Override
	public HashMap<String, Object> saveOrderTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		@SuppressWarnings("unchecked")
		List<HashMap<String, Object>> prdList = (List<HashMap<String, Object>>) paramMap.get("orderPrdList");

		// 재고 체크 (재고수량 0 = 재고 미관리 상품이므로 수량제한 없음)
		if (prdList != null) {
			for (int i = 0; i < prdList.size(); i++) {
				HashMap<String, Object> prdMap = prdList.get(i);

				HashMap<String, Object> stockMap = new HashMap<String, Object>();
				stockMap.put("prdCd", prdMap.get("prdCd"));
				int stockQty = orderMapper.selectPrdStockQty(stockMap);
				int ordQty = toInt(prdMap.get("ordQty"));

				if (stockQty > 0 && stockQty < ordQty) {
					rtnMap.put("rtnCode", "SOLD_OUT");
					rtnMap.put("rtnMsg", prdMap.get("prdNm") + " 상품의 재고가 부족합니다. (판매가능수량 " + stockQty + "개)");
					return rtnMap;
				}
			}
		}

		// 결제 준비를 거친 주문은 그때 만든 번호를 그대로 쓴다.
		// 결제창을 거치지 않는 결제수단은 임시 주문이 없으므로 여기서 만든다.
		String ordNo = (String) paramMap.get("ordNo");
		boolean fromTemp = (ordNo != null && !"".equals(ordNo.trim()));
		if (!fromTemp) {
			ordNo = newOrdNo();
			paramMap.put("ordNo", ordNo);
		}

		// 카드결제(20)는 PG 승인을 받아야 주문이 성립한다.
		// ※ 트랜잭션 안에서 외부 API를 동기 호출하므로 PG가 느려지면 DB 커넥션을 잡은 채 대기한다.
		//    타임아웃도 지정되어 있지 않아 지연이 그대로 주문 스레드 점유로 이어진다. (레거시 기술부채)
		if ("20".equals(paramMap.get("payTpCd"))) {
			long payAmt = toLong(paramMap.get("payAmt"));
			HashMap<String, Object> pgMap = pgApiUtil.approve(ordNo, payAmt);

			if (!"SUCCESS".equals(pgMap.get("rtnCode"))) {
				rtnMap.put("rtnCode", "PAY_FAIL");
				rtnMap.put("rtnMsg", pgMap.get("rtnMsg"));
				return rtnMap;
			}
			paramMap.put("pgAprvNo", pgMap.get("pgAprvNo"));
		}

		// 승인을 받은 뒤부터는 실패해도 DB 만 롤백된다. 승인은 PG 에 그대로 남는다.
		// 그래서 이 아래에서 터지면 승인을 되돌려야 한다.
		try {
			// 주문마스터 INSERT
			orderMapper.insertOrderMst(paramMap);

			// 주문상세 INSERT (상품별) + 재고 차감
			if (prdList != null) {
				for (int i = 0; i < prdList.size(); i++) {
					HashMap<String, Object> dtlMap = prdList.get(i);
					dtlMap.put("ordNo", ordNo);
					dtlMap.put("ordSeq", i + 1);
					orderMapper.insertOrderDtl(dtlMap);

					// 수량체크
					int salePssbQty = orderMapper.selectPrdStockQty(dtlMap);
					int dtlOrdQty = toInt(dtlMap.get("ordQty"));

					// 재고수량 0 = 재고 미관리 상품이므로 차감하지 않는다
					if (salePssbQty > 0) {
						orderMapper.updatePrdStockDecrease(dtlMap);

						// 재고 - 주문수량 <= 0 이면 일시품절(40)로 전환
						if ((salePssbQty - dtlOrdQty) <= 0) {
							orderMapper.updatePrdSoldOut(dtlMap);
						}
					}
				}
			}

			// 장바구니에서 주문한 경우 장바구니 삭제
			String fromCart = (String) paramMap.get("fromCart");
			if ("Y".equals(fromCart)) {
				HashMap<String, Object> delParam = new HashMap<String, Object>();
				delParam.put("ordNo", ordNo);
				cartMapper.deleteCartByList(delParam);
			}

			// 결제까지 끝났으므로 임시 주문을 지운다
			if (fromTemp) {
				HashMap<String, Object> tempParam = new HashMap<String, Object>();
				tempParam.put("ordNo", ordNo);
				orderMapper.deleteOrderTemp(tempParam);
			}

		} catch (Exception e) {
			// 승인을 받았다면 되돌린다. DB 는 예외를 다시 던져 롤백시킨다.
			String pgAprvNo = (String) paramMap.get("pgAprvNo");
			if (pgAprvNo != null) {
				boolean canceled = pgApiUtil.cancel(ordNo, pgAprvNo);
				if (!canceled) {
					// 취소까지 실패하면 승인만 남는다. 여기서 할 수 있는 게 로그뿐이다.
					logger.error("PG 승인 취소 실패 - 주문번호:" + ordNo + " 승인번호:" + pgAprvNo
							+ " (승인만 남았으므로 수동 확인이 필요하다)");
				}
			}
			throw e;
		}

		rtnMap.put("rtnCode", "SUCCESS");
		rtnMap.put("ordNo", ordNo);
		return rtnMap;
	}

	private int toInt(Object val) {
		if (val == null) return 0;
		if (val instanceof Number) return ((Number) val).intValue();
		try { return Integer.parseInt(val.toString().trim()); } catch (NumberFormatException e) { return 0; }
	}

	private long toLong(Object val) {
		if (val == null) return 0L;
		if (val instanceof Number) return ((Number) val).longValue();
		try { return Long.parseLong(val.toString().trim()); } catch (NumberFormatException e) { return 0L; }
	}

	@Override
	public HashMap<String, Object> selectOrderResult(HashMap<String, Object> paramMap) throws Exception {
		return orderMapper.selectOrderResult(paramMap);
	}

	@Override
	public List<HashMap<String, Object>> selectOrderDtlList(HashMap<String, Object> paramMap) throws Exception {
		return orderMapper.selectOrderDtlList(paramMap);
	}
}