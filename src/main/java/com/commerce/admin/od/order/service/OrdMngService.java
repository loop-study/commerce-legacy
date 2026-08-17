package com.commerce.admin.od.order.service;

import java.util.HashMap;
import java.util.List;

public interface OrdMngService {

    List<HashMap<String, Object>> selectOrdMngList(HashMap<String, Object> paramMap) throws Exception;

    int selectOrdMngListCnt(HashMap<String, Object> paramMap) throws Exception;

    HashMap<String, Object> selectOrdMngDtl(HashMap<String, Object> paramMap) throws Exception;

    List<HashMap<String, Object>> selectOrdDtlList(HashMap<String, Object> paramMap) throws Exception;

    HashMap<String, Object> updateOrdStatTx(HashMap<String, Object> paramMap) throws Exception;

    HashMap<String, Object> selectOrdDelvInfo(HashMap<String, Object> paramMap) throws Exception;

    HashMap<String, Object> saveOrdDelvInfoTx(HashMap<String, Object> paramMap) throws Exception;
}