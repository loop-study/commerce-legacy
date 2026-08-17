package com.commerce.ec.my.order.service;

import java.util.HashMap;
import java.util.List;

public interface MyOrderService {
	List<HashMap<String, Object>> selectMyOrderList(HashMap<String, Object> paramMap) throws Exception;
	int selectMyOrderListCnt(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> selectMyOrderDtl(HashMap<String, Object> paramMap) throws Exception;
	List<HashMap<String, Object>> selectMyOrderPrdList(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> updateMyOrderCancelTx(HashMap<String, Object> paramMap) throws Exception;
}
