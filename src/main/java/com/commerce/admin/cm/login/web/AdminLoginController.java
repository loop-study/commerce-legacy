package com.commerce.admin.cm.login.web;

import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.commerce.admin.cm.login.service.AdminLoginService;
import com.commerce.ec.cmmn.utils.SessionUtil;

@Controller
@RequestMapping("/admin")
public class AdminLoginController {

	private static final Logger logger = LoggerFactory.getLogger(AdminLoginController.class);

	@Resource(name = "adminLoginService")
	private AdminLoginService adminLoginService;

	/**
	 * 관리자 로그인 페이지
	 */
	@RequestMapping("/login.do")
	public String adminLogin() {
		if (SessionUtil.getData("adminVO") != null) {
			return "redirect:/admin/gd/prdMng.do";
		}
		return "cm/adminLogin.adminLogin";
	}

	/**
	 * 관리자 로그인 처리 (AJAX)
	 */
	@RequestMapping("/selectLoginProc.do")
	@ResponseBody
	public HashMap<String, Object> selectLoginProc(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			rtnMap = adminLoginService.adminLoginProcTx(paramMap);
		} catch (Exception e) {
			logger.error("관리자 로그인 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 관리자 로그아웃
	 */
	@RequestMapping("/selectLogout.do")
	public String selectLogout() {
		logger.info("관리자 로그아웃 - " + SessionUtil.getData("adminVO"));
		SessionUtil.removeData("adminVO");
		return "redirect:/admin/login.do";
	}
}
