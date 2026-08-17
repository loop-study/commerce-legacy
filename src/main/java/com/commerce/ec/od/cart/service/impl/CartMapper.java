package com.commerce.ec.od.cart.service.impl;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CartMapper {
	List<HashMap<String, Object>> selectCartList(HashMap<String, Object> paramMap);
	int selectCartListCnt(HashMap<String, Object> paramMap);
	HashMap<String, Object> selectCartInfo(HashMap<String, Object> paramMap);
	int selectCartNo(HashMap<String, Object> paramMap);
	void insertCart(HashMap<String, Object> paramMap);
	void updateCartQty(HashMap<String, Object> paramMap);
	void updateCartAddQty(HashMap<String, Object> paramMap);
	void deleteCart(HashMap<String, Object> paramMap);
	void deleteCartByList(HashMap<String, Object> paramMap);
}
