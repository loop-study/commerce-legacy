package com.commerce.admin.od.order.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.commerce.admin.od.order.service.OrdMngService;

@Service("ordMngService")
public class OrdMngServiceImpl implements OrdMngService {

    @Resource(name = "ordMngMapper")
    private OrdMngMapper ordMngMapper;

    @Override
    public List<HashMap<String, Object>> selectOrdMngList(HashMap<String, Object> paramMap) throws Exception {
        return ordMngMapper.selectOrdMngList(paramMap);
    }

    @Override
    public int selectOrdMngListCnt(HashMap<String, Object> paramMap) throws Exception {
        return ordMngMapper.selectOrdMngListCnt(paramMap);
    }

    @Override
    public HashMap<String, Object> selectOrdMngDtl(HashMap<String, Object> paramMap) throws Exception {
        return ordMngMapper.selectOrdMngDtl(paramMap);
    }

    @Override
    public List<HashMap<String, Object>> selectOrdDtlList(HashMap<String, Object> paramMap) throws Exception {
        return ordMngMapper.selectOrdDtlList(paramMap);
    }

    /**
     * 주문 상태 변경
     * - 다음 단계로 1단계씩 진행(10→20→30→40→50)과 취소(90)만 허용
     * - 취소(90)는 배송완료(50) 전까지만 가능
     * - 취소(90), 배송완료(50) 상태는 더 이상 변경 불가
     */
    @Override
    public HashMap<String, Object> updateOrdStatTx(HashMap<String, Object> paramMap) throws Exception {
        HashMap<String, Object> rtnMap = new HashMap<String, Object>();

        HashMap<String, Object> ordDtl = ordMngMapper.selectOrdMngDtl(paramMap);
        if (ordDtl == null) {
            rtnMap.put("rtnCode", "FAIL");
            rtnMap.put("rtnMsg", "존재하지 않는 주문입니다.");
            return rtnMap;
        }

        String currStatCd = (String) ordDtl.get("ordStatCd");
        String ordStatCd = (String) paramMap.get("ordStatCd");

        /* 상태 전이 체크 */
        boolean validYn = false;
        if (currStatCd != null && ordStatCd != null
                && !"90".equals(currStatCd) && !"50".equals(currStatCd)) {
            if ("90".equals(ordStatCd)) {
                validYn = true;
            } else if ("20".equals(ordStatCd) || "30".equals(ordStatCd)
                    || "40".equals(ordStatCd) || "50".equals(ordStatCd)) {
                validYn = Integer.parseInt(ordStatCd) == Integer.parseInt(currStatCd) + 10;
            }
        }

        if (!validYn) {
            rtnMap.put("rtnCode", "FAIL");
            rtnMap.put("rtnMsg", "변경할 수 없는 주문 상태입니다.");
            return rtnMap;
        }

        ordMngMapper.updateOrdStat(paramMap);

        // 취소 시 재고 복원 (재고 미관리 상품은 SQL의 WHERE 조건에서 제외됨)
        if ("90".equals(ordStatCd)) {
            List<HashMap<String, Object>> prdList = ordMngMapper.selectOrdPrdQtyList(paramMap);
            if (prdList != null) {
                for (int i = 0; i < prdList.size(); i++) {
                    ordMngMapper.updatePrdStockRestore(prdList.get(i));
                }
            }
        }

        rtnMap.put("rtnCode", "SUCCESS");
        rtnMap.put("rtnMsg", "주문 상태가 변경되었습니다.");
        return rtnMap;
    }

    @Override
    public HashMap<String, Object> selectOrdDelvInfo(HashMap<String, Object> paramMap) throws Exception {
        return ordMngMapper.selectOrdDelvInfo(paramMap);
    }

    /**
     * 배송정보(택배사/송장번호) 등록·수정
     * - 배송준비(30) 이후 주문만 등록 가능
     * - 등록 시 주문상태가 배송준비(30)이면 배송중(40)으로 함께 변경
     */
    @Override
    public HashMap<String, Object> saveOrdDelvInfoTx(HashMap<String, Object> paramMap) throws Exception {
        HashMap<String, Object> rtnMap = new HashMap<String, Object>();

        HashMap<String, Object> ordDtl = ordMngMapper.selectOrdMngDtl(paramMap);
        if (ordDtl == null) {
            rtnMap.put("rtnCode", "FAIL");
            rtnMap.put("rtnMsg", "존재하지 않는 주문입니다.");
            return rtnMap;
        }

        String currStatCd = (String) ordDtl.get("ordStatCd");
        if ("10".equals(currStatCd) || "20".equals(currStatCd) || "90".equals(currStatCd)) {
            rtnMap.put("rtnCode", "FAIL");
            rtnMap.put("rtnMsg", "배송준비 이후 주문만 송장을 등록할 수 있습니다.");
            return rtnMap;
        }

        // 기존 배송정보가 있으면 수정, 없으면 등록
        HashMap<String, Object> delvInfo = ordMngMapper.selectOrdDelvInfo(paramMap);
        if (delvInfo == null) {
            ordMngMapper.insertOrdDelvInfo(paramMap);
        } else {
            ordMngMapper.updateOrdDelvInfo(paramMap);
        }

        // 배송준비(30) 상태였다면 배송중(40)으로 전환
        if ("30".equals(currStatCd)) {
            HashMap<String, Object> statMap = new HashMap<String, Object>();
            statMap.put("ordNo", paramMap.get("ordNo"));
            statMap.put("ordStatCd", "40");
            ordMngMapper.updateOrdStat(statMap);
        }

        rtnMap.put("rtnCode", "SUCCESS");
        rtnMap.put("rtnMsg", "배송정보가 등록되었습니다.");
        return rtnMap;
    }
}
