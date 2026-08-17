package com.commerce.ec.cmmn;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.commerce.ec.cmmn.utils.SessionUtil;

public class AdminLoginHandlerInterceptor extends HandlerInterceptorAdapter {

	private static final Logger logger = LoggerFactory.getLogger(AdminLoginHandlerInterceptor.class);

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		Object adminVO = SessionUtil.getData("adminVO");

		if (adminVO == null) {
			// AJAX 요청인 경우 : 화면단이 rtnCode 로 분기하므로 JSON 으로 응답한다.
			String ajaxHeader = request.getHeader("X-Requested-With");
			if ("XMLHttpRequest".equals(ajaxHeader)) {
				response.setContentType("application/json;charset=UTF-8");
				response.getWriter().write("{\"rtnCode\":\"LOGIN_REQUIRED\",\"rtnMsg\":\"관리자 로그인이 필요합니다.\"}");
				return false;
			}
			logger.info("관리자 로그인 필요 - " + request.getRequestURI());
			response.sendRedirect(request.getContextPath() + "/admin/login.do");
			return false;
		}

		return true;
	}
}
