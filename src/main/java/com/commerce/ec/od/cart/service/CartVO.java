package com.commerce.ec.od.cart.service;

import java.io.Serializable;

public class CartVO implements Serializable {

	private static final long serialVersionUID = 1L;

	private int cartNo;
	private String mbrNo;
	private String prdCd;
	private int ordQty;
	private String prdNm;
	private String smplDesc;
	private String imgPath;
	private long salePrc;
	private long cardDiscPrc;
	private long cashDiscPrc;
	private String prdStatCd;
	private int stockQty;

	public int getCartNo() { return cartNo; }
	public void setCartNo(int cartNo) { this.cartNo = cartNo; }
	public String getMbrNo() { return mbrNo; }
	public void setMbrNo(String mbrNo) { this.mbrNo = mbrNo; }
	public String getPrdCd() { return prdCd; }
	public void setPrdCd(String prdCd) { this.prdCd = prdCd; }
	public int getOrdQty() { return ordQty; }
	public void setOrdQty(int ordQty) { this.ordQty = ordQty; }
	public String getPrdNm() { return prdNm; }
	public void setPrdNm(String prdNm) { this.prdNm = prdNm; }
	public String getSmplDesc() { return smplDesc; }
	public void setSmplDesc(String smplDesc) { this.smplDesc = smplDesc; }
	public String getImgPath() { return imgPath; }
	public void setImgPath(String imgPath) { this.imgPath = imgPath; }
	public long getSalePrc() { return salePrc; }
	public void setSalePrc(long salePrc) { this.salePrc = salePrc; }
	public long getCardDiscPrc() { return cardDiscPrc; }
	public void setCardDiscPrc(long cardDiscPrc) { this.cardDiscPrc = cardDiscPrc; }
	public long getCashDiscPrc() { return cashDiscPrc; }
	public void setCashDiscPrc(long cashDiscPrc) { this.cashDiscPrc = cashDiscPrc; }
	public String getPrdStatCd() { return prdStatCd; }
	public void setPrdStatCd(String prdStatCd) { this.prdStatCd = prdStatCd; }
	public int getStockQty() { return stockQty; }
	public void setStockQty(int stockQty) { this.stockQty = stockQty; }
}
