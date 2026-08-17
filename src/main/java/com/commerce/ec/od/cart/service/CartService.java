package com.commerce.ec.od.cart.service;

import java.util.HashMap;
import java.util.List;

public interface CartService {
	List<HashMap<String, Object>> selectCartList(HashMap<String, Object> paramMap) throws Exception;
	int selectCartListCnt(HashMap<String, Object> paramMap) throws Exception;
	HashMap<String, Object> selectCartInfo(HashMap<String, Object> paramMap) throws Exception;
	void insertCartTx(HashMap<String, Object> paramMap) throws Exception;
	void updateCartQtyTx(HashMap<String, Object> paramMap) throws Exception;
	void deleteCartTx(HashMap<String, Object> paramMap) throws Exception;
	void deleteCartByOrdNoTx(String ordNo) throws Exception;
}
