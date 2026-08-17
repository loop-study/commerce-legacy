package com.commerce.ec.od.cart.web;

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

import com.commerce.ec.cmmn.utils.SessionUtil;
import com.commerce.ec.cm.login.service.MemberVO;
import com.commerce.ec.od.cart.service.CartService;

@Controller
@RequestMapping("/od/cart")
public class CartController {

	private static final Logger logger = LoggerFactory.getLogger(CartController.class);

	@Resource(name = "cartService")
	private CartService cartService;

	/**
	 * 장바구니 목록 페이지
	 */
	@RequestMapping("/cartInit.do")
	public String cartInit(ModelMap model) {
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				return "redirect:/login.do";
			}

			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("mbrNo", memberVO.getMbrNo());

			List<HashMap<String, Object>> cartList = cartService.selectCartList(paramMap);

			model.addAttribute("cartList", cartList);
		} catch (Exception e) {
			logger.error("장바구니 목록 조회 오류", e);
		}
		return "od/cart/cartList.main";
	}

	/**
	 * 장바구니 추가 (AJAX)
	 */
	@RequestMapping("/addCart.do")
	@ResponseBody
	public HashMap<String, Object> addCart(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				rtnMap.put("rtnMsg", "로그인이 필요합니다.");
				return rtnMap;
			}

			paramMap.put("mbrNo", memberVO.getMbrNo());
			cartService.insertCartTx(paramMap);

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("rtnMsg", "장바구니에 담았습니다.");
		} catch (Exception e) {
			logger.error("장바구니 추가 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 장바구니 수량 변경 (AJAX)
	 */
	@RequestMapping("/updateCart.do")
	@ResponseBody
	public HashMap<String, Object> updateCart(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				rtnMap.put("rtnMsg", "로그인이 필요합니다.");
				return rtnMap;
			}

			paramMap.put("mbrNo", memberVO.getMbrNo());
			cartService.updateCartQtyTx(paramMap);

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("rtnMsg", "수량이 변경되었습니다.");
		} catch (Exception e) {
			logger.error("장바구니 수량 변경 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 장바구니 삭제 (AJAX)
	 */
	@RequestMapping("/deleteCart.do")
	@ResponseBody
	public HashMap<String, Object> deleteCart(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			MemberVO memberVO = SessionUtil.getSessionData();
			if (memberVO == null) {
				rtnMap.put("rtnCode", "LOGIN_REQUIRED");
				rtnMap.put("rtnMsg", "로그인이 필요합니다.");
				return rtnMap;
			}

			paramMap.put("mbrNo", memberVO.getMbrNo());
			cartService.deleteCartTx(paramMap);

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("rtnMsg", "삭제되었습니다.");
		} catch (Exception e) {
			logger.error("장바구니 삭제 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}
}