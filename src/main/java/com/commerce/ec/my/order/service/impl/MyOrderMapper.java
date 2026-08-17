package com.commerce.ec.my.order.service.impl;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MyOrderMapper {
	List<HashMap<String, Object>> selectMyOrderList(HashMap<String, Object> paramMap);
	int selectMyOrderListCnt(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectMyOrderDtl(HashMap<String, Object> paramMap);
	List<HashMap<String, Object>> selectMyOrderPrdList(HashMap<String, Object> paramMap);
	int updateMyOrderCancel(HashMap<String, Object> paramMap);
	List<HashMap<String, Object>> selectOrderPrdQtyList(HashMap<String, Object> paramMap);
	int updatePrdStockRestore(HashMap<String, Object> paramMap);
}
