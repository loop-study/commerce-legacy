package com.commerce.ec.my.order.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.ec.my.order.service.MyOrderService;

@Service("myOrderService")
public class MyOrderServiceImpl implements MyOrderService {

	private static final Logger logger = LoggerFactory.getLogger(MyOrderServiceImpl.class);

	@Resource(name = "myOrderMapper")
	private MyOrderMapper myOrderMapper;

	@Override
	public List<HashMap<String, Object>> selectMyOrderList(HashMap<String, Object> paramMap) throws Exception {
		return myOrderMapper.selectMyOrderList(paramMap);
	}

	@Override
	public int selectMyOrderListCnt(HashMap<String, Object> paramMap) throws Exception {
		return myOrderMapper.selectMyOrderListCnt(paramMap);
	}

	@Override
	public HashMap<String, Object> selectMyOrderDtl(HashMap<String, Object> paramMap) throws Exception {
		return myOrderMapper.selectMyOrderDtl(paramMap);
	}

	@Override
	public List<HashMap<String, Object>> selectMyOrderPrdList(HashMap<String, Object> paramMap) throws Exception {
		return myOrderMapper.selectMyOrderPrdList(paramMap);
	}

	/**
	 * 주문 취소 (주문확인/결제완료 상태만 가능) + 재고 복원
	 */
	@Override
	public HashMap<String, Object> updateMyOrderCancelTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		int updateCnt = myOrderMapper.updateMyOrderCancel(paramMap);
		if (updateCnt < 1) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "취소할 수 없는 주문입니다.");
			return rtnMap;
		}

		// 재고 복원 (재고 미관리 상품은 SQL의 WHERE 조건에서 제외됨)
		List<HashMap<String, Object>> prdList = myOrderMapper.selectOrderPrdQtyList(paramMap);
		if (prdList != null) {
			for (int i = 0; i < prdList.size(); i++) {
				myOrderMapper.updatePrdStockRestore(prdList.get(i));
			}
		}

		rtnMap.put("rtnCode", "SUCCESS");
		rtnMap.put("rtnMsg", "주문이 취소되었습니다.");
		return rtnMap;
	}
}
