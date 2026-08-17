package com.commerce.ec.od.order.service.impl;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface OrderMapper {
	List<HashMap<String, Object>> selectOrderPrdListFromCart(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectOrderPrdInfo(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectMbrInfo(HashMap<String, Object> paramMap);
	String selectMaxOrdNo(HashMap<String, Object> paramMap);
	void insertOrderTemp(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectOrderTemp(HashMap<String, Object> paramMap);
	int deleteOrderTemp(HashMap<String, Object> paramMap);
	void insertOrderMst(HashMap<String, Object> paramMap);
	void insertOrderDtl(HashMap<String, Object> paramMap);
	int selectPrdStockQty(HashMap<String, Object> paramMap);
	int updatePrdStockDecrease(HashMap<String, Object> paramMap);
	int updatePrdSoldOut(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectOrderResult(HashMap<String, Object> paramMap);
	List<HashMap<String, Object>> selectOrderDtlList(HashMap<String, Object> paramMap);
}