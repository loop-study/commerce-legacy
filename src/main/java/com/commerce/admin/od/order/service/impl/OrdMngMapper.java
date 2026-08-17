package com.commerce.admin.od.order.service.impl;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrdMngMapper {

    List<HashMap<String, Object>> selectOrdMngList(HashMap<String, Object> paramMap);

    int selectOrdMngListCnt(HashMap<String, Object> paramMap);

    HashMap<String, Object> selectOrdMngDtl(HashMap<String, Object> paramMap);

    List<HashMap<String, Object>> selectOrdDtlList(HashMap<String, Object> paramMap);

    int updateOrdStat(HashMap<String, Object> paramMap);

    HashMap<String, Object> selectOrdDelvInfo(HashMap<String, Object> paramMap);

    int insertOrdDelvInfo(HashMap<String, Object> paramMap);

    int updateOrdDelvInfo(HashMap<String, Object> paramMap);

    List<HashMap<String, Object>> selectOrdPrdQtyList(HashMap<String, Object> paramMap);

    int updatePrdStockRestore(HashMap<String, Object> paramMap);
}
