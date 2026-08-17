package com.commerce.ec.od.order.service;

import java.io.Serializable;

public class OrdVO implements Serializable {

	private static final long serialVersionUID = 1L;

	// 주문마스터
	private String ordNo;
	private String mbrNo;
	private String ordDt;
	private String ordStatCd;
	private String payTpCd;
	private long payAmt;
	private long delvAmt;

	// 배송정보
	private String depositorNm;
	private String reciverNm;
	private String delvHpNo;
	private String delvZipcode;
	private String delvBaseAddr;
	private String delvDtlAddr;
	private String delvMsg;

	// 주문상세
	private int ordSeq;
	private String prdCd;
	private String prdNm;
	private int ordQty;
	private long ordAmt;
	private long salePrc;
	private long discAmt;
	private String delvStatCd;

	// 조회용
	private String imgPath;
	private String smplDesc;
	private String ordStatNm;
	private String payTpNm;

	public String getOrdNo() { return ordNo; }
	public void setOrdNo(String ordNo) { this.ordNo = ordNo; }
	public String getMbrNo() { return mbrNo; }
	public void setMbrNo(String mbrNo) { this.mbrNo = mbrNo; }
	public String getOrdDt() { return ordDt; }
	public void setOrdDt(String ordDt) { this.ordDt = ordDt; }
	public String getOrdStatCd() { return ordStatCd; }
	public void setOrdStatCd(String ordStatCd) { this.ordStatCd = ordStatCd; }
	public String getPayTpCd() { return payTpCd; }
	public void setPayTpCd(String payTpCd) { this.payTpCd = payTpCd; }
	public long getPayAmt() { return payAmt; }
	public void setPayAmt(long payAmt) { this.payAmt = payAmt; }
	public long getDelvAmt() { return delvAmt; }
	public void setDelvAmt(long delvAmt) { this.delvAmt = delvAmt; }
	public String getDepositorNm() { return depositorNm; }
	public void setDepositorNm(String depositorNm) { this.depositorNm = depositorNm; }
	public String getReciverNm() { return reciverNm; }
	public void setReciverNm(String reciverNm) { this.reciverNm = reciverNm; }
	public String getDelvHpNo() { return delvHpNo; }
	public void setDelvHpNo(String delvHpNo) { this.delvHpNo = delvHpNo; }
	public String getDelvZipcode() { return delvZipcode; }
	public void setDelvZipcode(String delvZipcode) { this.delvZipcode = delvZipcode; }
	public String getDelvBaseAddr() { return delvBaseAddr; }
	public void setDelvBaseAddr(String delvBaseAddr) { this.delvBaseAddr = delvBaseAddr; }
	public String getDelvDtlAddr() { return delvDtlAddr; }
	public void setDelvDtlAddr(String delvDtlAddr) { this.delvDtlAddr = delvDtlAddr; }
	public String getDelvMsg() { return delvMsg; }
	public void setDelvMsg(String delvMsg) { this.delvMsg = delvMsg; }
	public int getOrdSeq() { return ordSeq; }
	public void setOrdSeq(int ordSeq) { this.ordSeq = ordSeq; }
	public String getPrdCd() { return prdCd; }
	public void setPrdCd(String prdCd) { this.prdCd = prdCd; }
	public String getPrdNm() { return prdNm; }
	public void setPrdNm(String prdNm) { this.prdNm = prdNm; }
	public int getOrdQty() { return ordQty; }
	public void setOrdQty(int ordQty) { this.ordQty = ordQty; }
	public long getOrdAmt() { return ordAmt; }
	public void setOrdAmt(long ordAmt) { this.ordAmt = ordAmt; }
	public long getSalePrc() { return salePrc; }
	public void setSalePrc(long salePrc) { this.salePrc = salePrc; }
	public long getDiscAmt() { return discAmt; }
	public void setDiscAmt(long discAmt) { this.discAmt = discAmt; }
	public String getDelvStatCd() { return delvStatCd; }
	public void setDelvStatCd(String delvStatCd) { this.delvStatCd = delvStatCd; }
	public String getImgPath() { return imgPath; }
	public void setImgPath(String imgPath) { this.imgPath = imgPath; }
	public String getSmplDesc() { return smplDesc; }
	public void setSmplDesc(String smplDesc) { this.smplDesc = smplDesc; }
	public String getOrdStatNm() { return ordStatNm; }
	public void setOrdStatNm(String ordStatNm) { this.ordStatNm = ordStatNm; }
	public String getPayTpNm() { return payTpNm; }
	public void setPayTpNm(String payTpNm) { this.payTpNm = payTpNm; }
}