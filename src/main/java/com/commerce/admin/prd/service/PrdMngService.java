package com.commerce.admin.prd.service;

import java.util.HashMap;
import java.util.List;

public interface PrdMngService {
	List<HashMap<String, Object>> selectPrdMngList(HashMap<String, Object> paramMap) throws Exception;
	int selectPrdMngListCnt(HashMap<String, Object> paramMap) throws Exception;
	PrdRegVO selectPrdMngDtl(HashMap<String, Object> paramMap) throws Exception;
	List<HashMap<String, Object>> selectCategoryByLevel(int catLvl) throws Exception;
	List<HashMap<String, Object>> selectSubCategoryList(String upCatCd) throws Exception;
	List<HashMap<String, Object>> selectPrdDtlImgList(String prdCd) throws Exception;
	HashMap<String, Object> savePrdTx(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> updatePrdStatTx(HashMap<String, Object> paramMap) throws Exception;
}
