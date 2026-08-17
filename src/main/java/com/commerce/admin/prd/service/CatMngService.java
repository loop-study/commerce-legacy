package com.commerce.admin.prd.service;

import java.util.HashMap;
import java.util.List;

public interface CatMngService {

	List<HashMap<String, Object>> selectCatMngList(HashMap<String, Object> paramMap) throws Exception;

	HashMap<String, Object> selectCatMngDtl(String catCd) throws Exception;

	HashMap<String, Object> saveCatTx(HashMap<String, Object> paramMap) throws Exception;

	HashMap<String, Object> deleteCatTx(HashMap<String, Object> paramMap) throws Exception;
}
