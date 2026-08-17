package com.commerce.ec.cmmn.utils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.commerce.ec.cm.login.service.MemberVO;

public class SessionUtil {

	private SessionUtil() {}

	private static HttpServletRequest getRequest() {
		ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
		if (attrs == null) return null;
		return attrs.getRequest();
	}

	public static String getLoginId() {
		MemberVO memberVO = getSessionData();
		if (memberVO != null) {
			return memberVO.getLoginId();
		}
		return "";
	}

	public static MemberVO getSessionData() {
		HttpServletRequest request = getRequest();
		if (request == null) return null;
		HttpSession session = request.getSession(false);
		if (session != null) {
			return (MemberVO) session.getAttribute("memberVO");
		}
		return null;
	}

	public static void setSessionData(MemberVO memberVO) {
		HttpServletRequest request = getRequest();
		if (request == null) return;
		request.getSession().setAttribute("memberVO", memberVO);
	}

	public static Object getData(String key) {
		HttpServletRequest request = getRequest();
		if (request == null) return null;
		HttpSession session = request.getSession(false);
		if (session != null) {
			return session.getAttribute(key);
		}
		return null;
	}

	public static void setData(String key, Object value) {
		HttpServletRequest request = getRequest();
		if (request == null) return;
		request.getSession().setAttribute(key, value);
	}

	public static void removeSession() {
		HttpServletRequest request = getRequest();
		if (request == null) return;
		HttpSession session = request.getSession(false);
		if (session != null) {
			session.invalidate();
		}
	}

	public static void removeData(String key) {
		HttpServletRequest request = getRequest();
		if (request == null) return;
		HttpSession session = request.getSession(false);
		if (session != null) {
			session.removeAttribute(key);
		}
	}

	public static String getMbrNo() {
		MemberVO memberVO = getSessionData();
		if (memberVO != null) {
			return memberVO.getMbrNo();
		}
		return "F000000000"; // 비회원
	}
}
