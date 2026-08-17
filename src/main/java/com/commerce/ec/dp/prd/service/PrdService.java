package com.commerce.ec.dp.prd.service;

import java.util.HashMap;
import java.util.List;

public interface PrdService {
	List<HashMap<String, Object>> selectPrdList(HashMap<String, Object> paramMap) throws Exception;
	int selectPrdListCnt(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> selectPrdDtlInfo(HashMap<String, Object> paramMap) throws Exception;
	List<HashMap<String, Object>> selectPrdImgList(HashMap<String, Object> paramMap) throws Exception;
	List<HashMap<String, Object>> selectCategoryList() throws Exception;
	List<HashMap<String, Object>> selectSubCategoryList(String upCatCd) throws Exception;
}