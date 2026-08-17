package com.commerce.ec.od.cart.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.ec.od.cart.service.CartService;

@Service("cartService")
public class CartServiceImpl implements CartService {

	private static final Logger logger = LoggerFactory.getLogger(CartServiceImpl.class);

	@Resource(name = "cartMapper")
	private CartMapper cartMapper;

	@Override
	public List<HashMap<String, Object>> selectCartList(HashMap<String, Object> paramMap) throws Exception {
		return cartMapper.selectCartList(paramMap);
	}

	@Override
	public int selectCartListCnt(HashMap<String, Object> paramMap) throws Exception {
		return cartMapper.selectCartListCnt(paramMap);
	}

	@Override
	public HashMap<String, Object> selectCartInfo(HashMap<String, Object> paramMap) throws Exception {
		return cartMapper.selectCartInfo(paramMap);
	}

	@Override
	public void insertCartTx(HashMap<String, Object> paramMap) throws Exception {
		// 이미 같은 상품이 장바구니에 있는지 체크
		int cnt = cartMapper.selectCartNo(paramMap);
		if (cnt > 0) {
			// 기존 상품이면 수량 추가
			cartMapper.updateCartAddQty(paramMap);
		} else {
			// 새 상품이면 INSERT
			cartMapper.insertCart(paramMap);
		}
	}

	@Override
	public void updateCartQtyTx(HashMap<String, Object> paramMap) throws Exception {
		cartMapper.updateCartQty(paramMap);
	}

	@Override
	public void deleteCartTx(HashMap<String, Object> paramMap) throws Exception {
		cartMapper.deleteCart(paramMap);
	}

	@Override
	public void deleteCartByOrdNoTx(String ordNo) throws Exception {
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("ordNo", ordNo);
		cartMapper.deleteCartByList(paramMap);
	}
}
