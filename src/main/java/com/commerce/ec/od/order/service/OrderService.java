package com.commerce.ec.od.order.service;

import java.util.HashMap;
import java.util.List;

public interface OrderService {
	List<HashMap<String, Object>> selectOrderPrdList(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> selectMbrInfo(HashMap<String, Object> paramMap) throws Exception;
	String insertOrderTempTx(HashMap<String, Object> paramMap, List<HashMap<String, Object>> orderPrdList) throws Exception;
	HashMap<String, Object> selectOrderTemp(HashMap<String, Object> paramMap) throws Exception;
	List<HashMap<String, Object>> selectOrderPrdListByTemp(HashMap<String, Object> tempOrder) throws Exception;
	HashMap<String, Object> saveOrderTx(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> selectOrderResult(HashMap<String, Object> paramMap) throws Exception;
	List<HashMap<String, Object>> selectOrderDtlList(HashMap<String, Object> paramMap) throws Exception;
}