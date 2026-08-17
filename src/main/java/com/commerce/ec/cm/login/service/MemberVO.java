package com.commerce.ec.cm.login.service;

import java.io.Serializable;

public class MemberVO implements Serializable {

	private static final long serialVersionUID = 3520653899227948119L;

	private String mbrNo	= "";
	private String mbrNm	= "";
	private String loginId 	= "";
	private String mbrGrdCd = "";
	private String mbrGrdNm = "";
	private String hpNo    = "";

	public void setHpNo(String hpNo) {
		this.hpNo = hpNo;
	}
	public String getHpNo() {
		if (hpNo == null) return "";
		return hpNo.replaceAll("-", "");
	}
	public String getMbrNo() {
		return mbrNo;
	}
	public void setMbrNo(String mbrNo) {
		this.mbrNo = mbrNo;
	}
	public String getMbrNm() {
		return mbrNm;
	}
	public void setMbrNm(String mbrNm) {
		this.mbrNm = mbrNm;
	}
	public String getLoginId() {
		return loginId;
	}
	public void setLoginId(String loginId) {
		this.loginId = loginId;
	}
	public String getMbrGrdCd() {
		return mbrGrdCd;
	}
	public void setMbrGrdCd(String mbrGrdCd) {
		this.mbrGrdCd = mbrGrdCd;
	}
	public String getMbrGrdNm() {
		return mbrGrdNm;
	}
	public void setMbrGrdNm(String mbrGrdNm) {
		this.mbrGrdNm = mbrGrdNm;
	}
	@Override
	public String toString() {
		return "MemberVO [mbrNo=" + mbrNo + ", mbrNm=" + mbrNm + ", loginId=" + loginId
				+ ", mbrGrdCd=" + mbrGrdCd + ", mbrGrdNm=" + mbrGrdNm + ", hpNo=" + hpNo + "]";
	}
}