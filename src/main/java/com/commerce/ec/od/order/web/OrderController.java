package com.commerce.ec.od.order.web;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.commerce.ec.cm.login.service.MemberVO;
import com.commerce.ec.cmmn.CmmnMessage;
import com.commerce.ec.cmmn.utils.SessionUtil;
import com.commerce.ec.od.order.service.OrderService;

@Controller
@RequestMapping("/od/order")
public class OrderController {

	private static final Logger logger = LoggerFactory.getLogger(OrderController.class);

	@Resource(name = "orderService")
	private OrderService orderService;

	@Resource
	private CmmnMessage cmmnMessage;

	/**
	 * 주문서 페이지
	 */
	@RequestMapping("/orderInit.do")
	public String orderInit(@RequestParam(required = false) String fromCart,
							@RequestParam(required = false) String cartNoList,
							@RequestParam(required = false) String prdCd,
							@RequestParam(required = false, defaultValue = "1") int ordQty,
							ModelMap model) {
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				return "redirect:/login.do";
			}

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("mbrNo", memberVO.getMbrNo());
			paramMap.put("fromCart", fromCart);
			paramMap.put("cartNoList", cartNoList);
			paramMap.put("prdCd", prdCd);
			paramMap.put("ordQty", ordQty);

			// 주문 상품 목록
			List<HashMap<String, Object>> orderPrdList = orderService.selectOrderPrdList(paramMap);

			// 회원 정보 (배송지용)
			HashMap<String, Object> mbrInfo = orderService.selectMbrInfo(paramMap);

			model.addAttribute("orderPrdList", orderPrdList);
			model.addAttribute("mbrInfo", mbrInfo);
			model.addAttribute("fromCart", fromCart);
			model.addAttribute("cartNoList", cartNoList);

		} catch (Exception e) {
			logger.error("주문서 조회 오류", e);
		}
		return "od/order/orderForm.main";
	}

	/**
	 * 결제 준비 (AJAX)
	 *
	 * 결제창을 거치는 결제수단만 이 단계를 탄다.
	 * 주문번호를 만들고 선택한 상품·수량을 임시 주문에 담아둔 뒤 번호를 돌려준다.
	 * 결제가 확정되면 saveOrder 가 그 행을 지운다.
	 */
	@RequestMapping("/prepareOrder.do")
	@ResponseBody
	public HashMap<String, Object> prepareOrder(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				return rtnMap;
			}

			paramMap.put("mbrNo", memberVO.getMbrNo());

			List<HashMap<String, Object>> orderPrdList = orderService.selectOrderPrdList(paramMap);
			if (orderPrdList == null || orderPrdList.isEmpty()) {
				rtnMap.put("rtnCode", "ERROR");
				rtnMap.put("rtnMsg", "주문 상품이 없습니다.");
				return rtnMap;
			}

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("ordNo", orderService.insertOrderTempTx(paramMap, orderPrdList));

		} catch (Exception e) {
			logger.error("결제 준비 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 주문 저장 (AJAX)
	 */
	@RequestMapping("/saveOrder.do")
	@ResponseBody
	public HashMap<String, Object> saveOrder(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				return rtnMap;
			}

			paramMap.put("mbrNo", memberVO.getMbrNo());

			String ordNo = (String) paramMap.get("ordNo");
			List<HashMap<String, Object>> orderPrdList;

			if (ordNo != null && !"".equals(ordNo.trim())) {
				// 결제 준비를 거친 주문. 임시 주문에 담아둔 내용으로 확정한다.
				// 이미 결제가 끝난 번호라면 행이 없으므로 여기서 걸린다.
				HashMap<String, Object> tempOrder = orderService.selectOrderTemp(paramMap);
				if (tempOrder == null) {
					rtnMap.put("rtnCode", "ERROR");
					rtnMap.put("rtnMsg", "주문 정보를 찾을 수 없습니다. 주문서를 다시 열어주세요.");
					return rtnMap;
				}

				// 장바구니 여부도 화면 값이 아니라 임시 주문에 담아둔 것을 쓴다
				paramMap.put("fromCart", tempOrder.get("fromCart"));
				paramMap.put("cartNoList", tempOrder.get("cartNoList"));

				orderPrdList = orderService.selectOrderPrdListByTemp(tempOrder);
			} else {
				// 결제창을 거치지 않는 결제수단. 임시 주문 없이 화면 값으로 바로 확정한다.
				orderPrdList = orderService.selectOrderPrdList(paramMap);
			}

			if (orderPrdList == null || orderPrdList.isEmpty()) {
				rtnMap.put("rtnCode", "ERROR");
				rtnMap.put("rtnMsg", "주문 상품이 없습니다.");
				return rtnMap;
			}

			// 총 결제금액 계산 (결제수단에 따른 할인가 적용)
			String payTpCd = (String) paramMap.get("payTpCd");

			// 무통장입금은 입금자명 필수 (입금 대조용)
			if ("10".equals(payTpCd)) {
				String depositorNm = (String) paramMap.get("depositorNm");
				if (depositorNm == null || "".equals(depositorNm.trim())) {
					rtnMap.put("rtnCode", "FAIL");
					rtnMap.put("rtnMsg", "입금자명을 입력해주세요.");
					return rtnMap;
				}
			}

			long totalPayAmt = 0;
			for (HashMap<String, Object> prd : orderPrdList) {
				long salePrc = toLong(prd.get("salePrc"));
				int qty = toInt(prd.get("ordQty"));

				long effectivePrc = salePrc;
				long cardDiscPrc = toLong(prd.get("cardDiscPrc"));
				long cashDiscPrc = toLong(prd.get("cashDiscPrc"));

				if ("20".equals(payTpCd) && cardDiscPrc > 0) {
					effectivePrc = cardDiscPrc;
				} else if ("10".equals(payTpCd) && cashDiscPrc > 0) {
					effectivePrc = cashDiscPrc;
				}

				prd.put("effectivePrc", effectivePrc);
				prd.put("discAmt", (salePrc - effectivePrc) * qty);
				prd.put("ordAmt", effectivePrc * qty);
				totalPayAmt += effectivePrc * qty;
			}
			paramMap.put("payAmt", totalPayAmt);
			paramMap.put("orderPrdList", orderPrdList);

			// 주문 저장 (재고 부족 시 SOLD_OUT 반환)
			rtnMap = orderService.saveOrderTx(paramMap);

		} catch (Exception e) {
			logger.error("주문 저장 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	private static long toLong(Object val) {
		if (val == null) return 0L;
		if (val instanceof Number) return ((Number) val).longValue();
		try { return Long.parseLong(val.toString().trim()); } catch (Exception e) { return 0L; }
	}

	private static int toInt(Object val) {
		if (val == null) return 0;
		if (val instanceof Number) return ((Number) val).intValue();
		try { return Integer.parseInt(val.toString().trim()); } catch (Exception e) { return 0; }
	}

	/**
	 * 주문 완료 페이지
	 */
	@RequestMapping("/orderSuccess.do")
	public String orderSuccess(@RequestParam String ordNo, ModelMap model) {
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				return "redirect:/login.do";
			}

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("ordNo", ordNo);
			paramMap.put("mbrNo", memberVO.getMbrNo());

			// 주문 결과 조회
			HashMap<String, Object> orderInfo = orderService.selectOrderResult(paramMap);
			List<HashMap<String, Object>> orderDtlList = orderService.selectOrderDtlList(paramMap);

			model.addAttribute("orderInfo", orderInfo);
			model.addAttribute("orderDtlList", orderDtlList);

			// 무통장입금 계좌 안내 (message-common.properties)
			model.addAttribute("bankNm", cmmnMessage.getMessage("pay.bank.nm"));
			model.addAttribute("bankAccount", cmmnMessage.getMessage("pay.bank.account"));
			model.addAttribute("bankHolder", cmmnMessage.getMessage("pay.bank.holder"));

		} catch (Exception e) {
			logger.error("주문 완료 조회 오류", e);
		}
		return "od/order/orderSuccess.main";
	}
}