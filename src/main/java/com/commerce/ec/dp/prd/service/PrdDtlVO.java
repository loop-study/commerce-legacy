package com.commerce.ec.dp.prd.service;

public class PrdDtlVO {

	// 상품 정보
	private String prdCd;
	private String prdNm;
	private String smplDesc;
	private String prdStatCd;
	private String imgPath;
	private String delvTpCd;

	// 카테고리
	private String lCatCd;
	private String lCatNm;
	private String mCatCd;
	private String mCatNm;
	private String sCatCd;
	private String sCatNm;

	// 재고 관련
	private int stockQty;

	// 가격
	private long salePrc;
	private long cardDiscPrc;
	private long cashDiscPrc;

	public String getPrdCd() { return prdCd; }
	public void setPrdCd(String prdCd) { this.prdCd = prdCd; }
	public String getPrdNm() { return prdNm; }
	public void setPrdNm(String prdNm) { this.prdNm = prdNm; }
	public String getSmplDesc() { return smplDesc; }
	public void setSmplDesc(String smplDesc) { this.smplDesc = smplDesc; }
	public String getPrdStatCd() { return prdStatCd; }
	public void setPrdStatCd(String prdStatCd) { this.prdStatCd = prdStatCd; }
	public String getLCatCd() { return lCatCd; }
	public void setLCatCd(String lCatCd) { this.lCatCd = lCatCd; }
	public String getMCatCd() { return mCatCd; }
	public void setMCatCd(String mCatCd) { this.mCatCd = mCatCd; }
	public String getSCatCd() { return sCatCd; }
	public void setSCatCd(String sCatCd) { this.sCatCd = sCatCd; }
	public String getLCatNm() { return lCatNm; }
	public void setLCatNm(String lCatNm) { this.lCatNm = lCatNm; }
	public String getMCatNm() { return mCatNm; }
	public void setMCatNm(String mCatNm) { this.mCatNm = mCatNm; }
	public String getSCatNm() { return sCatNm; }
	public void setSCatNm(String sCatNm) { this.sCatNm = sCatNm; }
	public int getStockQty() { return stockQty; }
	public void setStockQty(int stockQty) { this.stockQty = stockQty; }
	public String getDelvTpCd() { return delvTpCd; }
	public void setDelvTpCd(String delvTpCd) { this.delvTpCd = delvTpCd; }
	public long getSalePrc() { return salePrc; }
	public void setSalePrc(long salePrc) { this.salePrc = salePrc; }
	public long getCardDiscPrc() { return cardDiscPrc; }
	public void setCardDiscPrc(long cardDiscPrc) { this.cardDiscPrc = cardDiscPrc; }
	public long getCashDiscPrc() { return cashDiscPrc; }
	public void setCashDiscPrc(long cashDiscPrc) { this.cashDiscPrc = cashDiscPrc; }
	public String getImgPath() { return imgPath; }
	public void setImgPath(String imgPath) { this.imgPath = imgPath; }
}
