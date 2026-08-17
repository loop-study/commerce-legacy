package com.commerce.ec.dp.prd.service.impl;

import org.apache.ibatis.annotations.Mapper;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface PrdMapper {
	List<HashMap<String, Object>> selectPrdList(HashMap<String, Object> paramMap);
	int selectPrdListCnt(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectPrdDtlInfo(HashMap<String, Object> paramMap);
	List<HashMap<String, Object>> selectPrdImgList(HashMap<String, Object> paramMap);
	List<HashMap<String, Object>> selectCategoryList();
	List<HashMap<String, Object>> selectSubCategoryList(String upCatCd);
}