package com.commerce.ec.cmmn;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.commerce.ec.cm.login.service.MemberVO;
import com.commerce.ec.cmmn.utils.SessionUtil;

public class LoginHandlerInterceptor extends HandlerInterceptorAdapter {

	private static final Logger logger = LoggerFactory.getLogger(LoginHandlerInterceptor.class);

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		MemberVO memberVO = SessionUtil.getSessionData();

		if (memberVO == null) {
			// AJAX 요청인 경우 : 화면단이 rtnCode 로 분기하므로 JSON 으로 응답한다.
			// (401 로 내려주면 jQuery 가 error 콜백을 타서 "시스템 오류"로 표시된다)
			String ajaxHeader = request.getHeader("X-Requested-With");
			if ("XMLHttpRequest".equals(ajaxHeader)) {
				response.setContentType("application/json;charset=UTF-8");
				response.getWriter().write("{\"rtnCode\":\"LOGIN_REQUIRED\",\"rtnMsg\":\"로그인이 필요합니다.\"}");
				return false;
			}

			// 일반 요청인 경우 로그인 페이지로 리다이렉트
			String returnUrl = request.getRequestURI();
			String queryString = request.getQueryString();
			if (queryString != null) {
				returnUrl += "?" + queryString;
			}

			logger.info("로그인 필요 - returnUrl: " + returnUrl);
			response.sendRedirect("/login.do?returnUrl=" + java.net.URLEncoder.encode(returnUrl, "UTF-8"));
			return false;
		}

		return true;
	}
}
