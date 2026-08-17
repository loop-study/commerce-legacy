package com.commerce.admin.prd.service;

public class PrdRegVO {

	private String prdCd;
	private String prdNm;
	private String smplDesc;
	private String prdStatCd;
	private String delvTpCd;
	private String lCatCd;
	private String mCatCd;
	private String sCatCd;
	private int stockQty;

	private long salePrc;
	private long cardDiscPrc;
	private long cashDiscPrc;
	private String imgPath;
	private String imgName;

	public String getPrdCd() { return prdCd; }
	public void setPrdCd(String prdCd) { this.prdCd = prdCd; }
	public String getPrdNm() { return prdNm; }
	public void setPrdNm(String prdNm) { this.prdNm = prdNm; }
	public String getSmplDesc() { return smplDesc; }
	public void setSmplDesc(String smplDesc) { this.smplDesc = smplDesc; }
	public String getPrdStatCd() { return prdStatCd; }
	public void setPrdStatCd(String prdStatCd) { this.prdStatCd = prdStatCd; }
	public String getDelvTpCd() { return delvTpCd; }
	public void setDelvTpCd(String delvTpCd) { this.delvTpCd = delvTpCd; }
	public String getLCatCd() { return lCatCd; }
	public void setLCatCd(String lCatCd) { this.lCatCd = lCatCd; }
	public String getMCatCd() { return mCatCd; }
	public void setMCatCd(String mCatCd) { this.mCatCd = mCatCd; }
	public String getSCatCd() { return sCatCd; }
	public void setSCatCd(String sCatCd) { this.sCatCd = sCatCd; }
	public int getStockQty() { return stockQty; }
	public void setStockQty(int stockQty) { this.stockQty = stockQty; }
	public long getSalePrc() { return salePrc; }
	public void setSalePrc(long salePrc) { this.salePrc = salePrc; }
	public long getCardDiscPrc() { return cardDiscPrc; }
	public void setCardDiscPrc(long cardDiscPrc) { this.cardDiscPrc = cardDiscPrc; }
	public long getCashDiscPrc() { return cashDiscPrc; }
	public void setCashDiscPrc(long cashDiscPrc) { this.cashDiscPrc = cashDiscPrc; }
	public String getImgPath() { return imgPath; }
	public void setImgPath(String imgPath) { this.imgPath = imgPath; }
	public String getImgName() { return imgName; }
	public void setImgName(String imgName) { this.imgName = imgName; }
}
