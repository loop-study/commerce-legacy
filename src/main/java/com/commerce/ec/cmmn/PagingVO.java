package com.commerce.ec.cmmn;

import java.util.HashMap;

public class PagingVO {

	private int page;
	private int rows = 10;
	private int totalTotCnt;
	private int pageScale = 10;
	private int startPage;
	private int endPage;
	private String param;
	private String order;
	private HashMap<String, Object> paramMap;

	public int getPage() {
		return page;
	}
	public void setPage(int page) {
		this.page = page;
	}
	public int getRows() {
		return rows;
	}
	public void setRows(int rows) {
		this.rows = rows;
	}
	public int getTotalTotCnt() {
		return totalTotCnt;
	}
	public void setTotalTotCnt(int totalTotCnt) {
		this.totalTotCnt = totalTotCnt;
	}
	public int getPageScale() {
		return pageScale;
	}
	public void setPageScale(int pageScale) {
		this.pageScale = pageScale;
	}
	public int getStartPage() {
		return startPage;
	}
	public void setStartPage(int startPage) {
		this.startPage = startPage;
	}
	public int getEndPage() {
		return endPage;
	}
	public void setEndPage(int endPage) {
		this.endPage = endPage;
	}
	public String getParam() {
		return param;
	}
	public void setParam(String param) {
		this.param = param;
	}
	public String getOrder() {
		return order;
	}
	public void setOrder(String order) {
		this.order = order;
	}
	public HashMap<String, Object> getParamMap() {
		return paramMap;
	}
	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
}
