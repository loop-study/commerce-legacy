package com.commerce.admin.cm.login.service;

import java.io.Serializable;

public class AdminVO implements Serializable {

	private static final long serialVersionUID = 1L;

	private String adminNo  = "";
	private String adminNm  = "";
	private String loginId  = "";

	public String getAdminNo() {
		return adminNo;
	}
	public void setAdminNo(String adminNo) {
		this.adminNo = adminNo;
	}
	public String getAdminNm() {
		return adminNm;
	}
	public void setAdminNm(String adminNm) {
		this.adminNm = adminNm;
	}
	public String getLoginId() {
		return loginId;
	}
	public void setLoginId(String loginId) {
		this.loginId = loginId;
	}
}