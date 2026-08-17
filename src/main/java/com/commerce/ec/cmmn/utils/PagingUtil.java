package com.commerce.ec.cmmn.utils;

import java.util.HashMap;

public class PagingUtil {

	public static void setPagingMap(HashMap<String, Object> map) {
		int pageNo = 1;
		int pageSize = 10;
		int pageScale = 10;
		int totalCnt = 0;

		if (map.get("pageNo") != null) {
			pageNo = Integer.parseInt(map.get("pageNo").toString());
		}
		if (map.get("pageSize") != null) {
			pageSize = Integer.parseInt(map.get("pageSize").toString());
		}
		if (map.get("totalCnt") != null) {
			totalCnt = Integer.parseInt(map.get("totalCnt").toString());
		}

		int totalPage = (int) Math.ceil((double) totalCnt / pageSize);
		if (totalPage == 0) totalPage = 1;
		if (pageNo > totalPage) pageNo = totalPage;

		int startPage = ((pageNo - 1) / pageScale) * pageScale + 1;
		int endPage = startPage + pageScale - 1;
		if (endPage > totalPage) endPage = totalPage;

		int prevPage = startPage > 1 ? startPage - 1 : 1;
		int nextPage = endPage < totalPage ? endPage + 1 : totalPage;

		int limitStart = (pageNo - 1) * pageSize;

		map.put("pageNo", pageNo);
		map.put("pageSize", pageSize);
		map.put("totalPage", totalPage);
		map.put("startPage", startPage);
		map.put("endPage", endPage);
		map.put("prevPage", prevPage);
		map.put("nextPage", nextPage);
		map.put("limitStart", limitStart);
		map.put("totalCnt", totalCnt);
	}
}
