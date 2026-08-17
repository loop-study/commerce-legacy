package com.commerce.admin.prd.service.impl;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CatMngMapper {
	List<HashMap<String, Object>> selectCatMngList(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectCatMngDtl(String catCd);
	String selectMaxCatCd(int catLvl);
	int insertCat(HashMap<String, Object> paramMap);
	int updateCat(HashMap<String, Object> paramMap);
	int deleteCat(String catCd);
	int selectSubCatCnt(String catCd);
	int selectCatPrdCnt(HashMap<String, Object> paramMap);
}
