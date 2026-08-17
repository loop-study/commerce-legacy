package com.commerce.admin.prd.service.impl;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.commerce.admin.prd.service.PrdRegVO;

@Mapper
public interface PrdMngMapper {
	List<HashMap<String, Object>> selectPrdMngList(HashMap<String, Object> paramMap);
	int selectPrdMngListCnt(HashMap<String, Object> paramMap);
	PrdRegVO selectPrdMngDtl(HashMap<String, Object> paramMap);
	List<HashMap<String, Object>> selectCategoryByLevel(int catLvl);
	List<HashMap<String, Object>> selectSubCategoryList(String upCatCd);
	String selectMaxPrdCd();
	int insertPrdMst(PrdRegVO prdRegVO);
	int insertPrdPrc(PrdRegVO prdRegVO);
	int insertPrdImg(PrdRegVO prdRegVO);
	int deletePrdImg(String prdCd);
	List<HashMap<String, Object>> selectPrdDtlImgList(String prdCd);
	int insertPrdDtlImg(HashMap<String, Object> paramMap);
	int deletePrdDtlImg(String prdCd);
	int updatePrdMst(PrdRegVO prdRegVO);
	int updatePrdPrc(PrdRegVO prdRegVO);
	int updatePrdStat(HashMap<String, Object> paramMap);
}
