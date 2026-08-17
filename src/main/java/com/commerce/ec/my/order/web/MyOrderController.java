package com.commerce.ec.my.order.web;

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
import com.commerce.ec.cmmn.utils.PagingUtil;
import com.commerce.ec.cmmn.utils.SessionUtil;
import com.commerce.ec.my.order.service.MyOrderService;

@Controller
@RequestMapping("/my/order")
public class MyOrderController {

	private static final Logger logger = LoggerFactory.getLogger(MyOrderController.class);

	@Resource(name = "myOrderService")
	private MyOrderService myOrderService;

	@Resource
	private CmmnMessage cmmnMessage;

	/**
	 * 주문내역 페이지
	 */
	@RequestMapping("/myOrderList.do")
	public String myOrderList(@RequestParam(defaultValue = "1") int pageNo,
							  @RequestParam(required = false) String searchPeriod,
							  ModelMap model) {
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				return "redirect:/login.do";
			}

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("mbrNo", memberVO.getMbrNo());
			paramMap.put("searchPeriod", searchPeriod);

			// 총 건수
			int totalCnt = myOrderService.selectMyOrderListCnt(paramMap);

			// 페이징
			paramMap.put("pageNo", pageNo);
			paramMap.put("pageSize", 10);
			paramMap.put("totalCnt", totalCnt);
			PagingUtil.setPagingMap(paramMap);

			// 목록 조회
			List<HashMap<String, Object>> orderList = myOrderService.selectMyOrderList(paramMap);

			model.addAttribute("orderList", orderList);
			model.addAttribute("totalCnt", totalCnt);
			model.addAttribute("pageNo", paramMap.get("pageNo"));
			model.addAttribute("startPage", paramMap.get("startPage"));
			model.addAttribute("endPage", paramMap.get("endPage"));
			model.addAttribute("prevPage", paramMap.get("prevPage"));
			model.addAttribute("nextPage", paramMap.get("nextPage"));
			model.addAttribute("totalPage", paramMap.get("totalPage"));
			model.addAttribute("searchPeriod", searchPeriod);

		} catch (Exception e) {
			logger.error("주문내역 조회 오류", e);
		}
		return "my/order/myOrderList.main";
	}

	/**
	 * 주문 상세 페이지
	 */
	@RequestMapping("/myOrderDtl.do")
	public String myOrderDtl(@RequestParam String ordNo, ModelMap model) {
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				return "redirect:/login.do";
			}

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("ordNo", ordNo);
			paramMap.put("mbrNo", memberVO.getMbrNo());

			// 본인 주문이 아니면 목록으로
			HashMap<String, Object> orderInfo = myOrderService.selectMyOrderDtl(paramMap);
			if (orderInfo == null) {
				return "redirect:/my/order/myOrderList.do";
			}

			model.addAttribute("orderInfo", orderInfo);
			model.addAttribute("orderPrdList", myOrderService.selectMyOrderPrdList(paramMap));

			// 무통장입금 계좌 안내 (message-common.properties)
			model.addAttribute("bankNm", cmmnMessage.getMessage("pay.bank.nm"));
			model.addAttribute("bankAccount", cmmnMessage.getMessage("pay.bank.account"));
			model.addAttribute("bankHolder", cmmnMessage.getMessage("pay.bank.holder"));

		} catch (Exception e) {
			logger.error("주문 상세 조회 오류", e);
		}
		return "my/order/myOrderDtl.main";
	}

	/**
	 * 주문내역 AJAX 검색
	 */
	@RequestMapping("/searchMyOrderList.do")
	@ResponseBody
	public HashMap<String, Object> searchMyOrderList(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				return rtnMap;
			}

			paramMap.put("mbrNo", memberVO.getMbrNo());

			int totalCnt = myOrderService.selectMyOrderListCnt(paramMap);
			paramMap.put("pageSize", 10);
			paramMap.put("totalCnt", totalCnt);
			PagingUtil.setPagingMap(paramMap);

			List<HashMap<String, Object>> orderList = myOrderService.selectMyOrderList(paramMap);

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("orderList", orderList);
			rtnMap.put("totalCnt", totalCnt);
			rtnMap.put("pageNo", paramMap.get("pageNo"));
			rtnMap.put("totalPage", paramMap.get("totalPage"));

		} catch (Exception e) {
			logger.error("주문내역 AJAX 검색 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 주문 취소 AJAX (주문확인/결제완료 상태만 가능)
	 */
	@RequestMapping("/cancelMyOrder.do")
	@ResponseBody
	public HashMap<String, Object> cancelMyOrder(@RequestParam String ordNo) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				return rtnMap;
			}

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("ordNo", ordNo);
			paramMap.put("mbrNo", memberVO.getMbrNo());

			rtnMap = myOrderService.updateMyOrderCancelTx(paramMap);

		} catch (Exception e) {
			logger.error("주문 취소 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}
}
