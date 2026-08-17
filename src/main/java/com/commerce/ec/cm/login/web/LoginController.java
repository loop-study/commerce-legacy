package com.commerce.ec.cm.login.web;

import java.util.HashMap;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.commerce.ec.cm.login.service.LoginService;
import com.commerce.ec.cmmn.utils.SessionUtil;

@Controller
public class LoginController {

	private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

	@Resource(name = "loginService")
	private LoginService loginService;

	/**
	 * 로그인 페이지
	 */
	@RequestMapping("/login.do")
	public String login(@RequestParam(value = "returnUrl", required = false) String returnUrl,
						ModelMap model) {
		// 이미 로그인되어 있으면 메인으로
		if (SessionUtil.getSessionData() != null) {
			return "redirect:/main.do";
		}
		model.addAttribute("returnUrl", returnUrl);
		return "cm/login/login.main";
	}

	/**
	 * 로그인 처리
	 */
	@RequestMapping("/selectLoginProc.do")
	@ResponseBody
	public HashMap<String, Object> selectLoginProc(@RequestParam HashMap<String, Object> paramMap,
												   HttpServletRequest request) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			rtnMap = loginService.loginProcTx(paramMap);
		} catch (Exception e) {
			e.printStackTrace();
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 로그아웃
	 */
	@RequestMapping("/selectLogout.do")
	public String selectLogout() {
		logger.info("로그아웃 - " + SessionUtil.getLoginId());
		SessionUtil.removeSession();
		return "redirect:/main.do";
	}
}