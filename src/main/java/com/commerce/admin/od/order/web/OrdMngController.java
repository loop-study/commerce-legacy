package com.commerce.admin.od.order.web;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.commerce.admin.od.order.service.OrdMngService;
import com.commerce.ec.cmmn.utils.PagingUtil;

@Controller
@RequestMapping("/admin/od")
public class OrdMngController {

    private static final Logger logger = LoggerFactory.getLogger(OrdMngController.class);

    @Resource(name = "ordMngService")
    private OrdMngService ordMngService;

    /**
     * 주문 관리 목록 페이지
     */
    @RequestMapping("/ordList.do")
    public String ordList(@RequestParam(defaultValue = "1") int pageNo,
                          @RequestParam(required = false) String searchPeriod,
                          @RequestParam(required = false) String ordStatCd,
                          @RequestParam(required = false) String payTpCd,
                          @RequestParam(required = false) String searchKeyword,
                          ModelMap model) {
        try {
            HashMap<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("searchPeriod", searchPeriod);
            paramMap.put("ordStatCd", ordStatCd);
            paramMap.put("payTpCd", payTpCd);
            paramMap.put("searchKeyword", searchKeyword);

            int totalCnt = ordMngService.selectOrdMngListCnt(paramMap);

            paramMap.put("pageNo", pageNo);
            paramMap.put("pageSize", 10);
            paramMap.put("totalCnt", totalCnt);
            PagingUtil.setPagingMap(paramMap);

            List<HashMap<String, Object>> ordList = ordMngService.selectOrdMngList(paramMap);

            model.addAttribute("ordList", ordList);
            model.addAttribute("totalCnt", totalCnt);
            model.addAttribute("pageNo", paramMap.get("pageNo"));
            model.addAttribute("startPage", paramMap.get("startPage"));
            model.addAttribute("endPage", paramMap.get("endPage"));
            model.addAttribute("prevPage", paramMap.get("prevPage"));
            model.addAttribute("nextPage", paramMap.get("nextPage"));
            model.addAttribute("totalPage", paramMap.get("totalPage"));
            model.addAttribute("searchPeriod", searchPeriod);
            model.addAttribute("ordStatCd", ordStatCd);
            model.addAttribute("payTpCd", payTpCd);
            model.addAttribute("searchKeyword", searchKeyword);

        } catch (Exception e) {
            logger.error("주문 관리 목록 조회 오류", e);
        }
        return "od/ordList.admin";
    }

    /**
     * 주문 상세 AJAX (모달용)
     */
    @RequestMapping("/selectOrdDtl.do")
    @ResponseBody
    public HashMap<String, Object> selectOrdDtl(@RequestParam String ordNo) {
        HashMap<String, Object> rtnMap = new HashMap<String, Object>();
        try {
            HashMap<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("ordNo", ordNo);

            HashMap<String, Object> ordDtl = ordMngService.selectOrdMngDtl(paramMap);
            List<HashMap<String, Object>> ordDtlList = ordMngService.selectOrdDtlList(paramMap);
            HashMap<String, Object> delvInfo = ordMngService.selectOrdDelvInfo(paramMap);

            rtnMap.put("rtnCode", "SUCCESS");
            rtnMap.put("ordDtl", ordDtl);
            rtnMap.put("ordDtlList", ordDtlList);
            rtnMap.put("delvInfo", delvInfo);

        } catch (Exception e) {
            logger.error("주문 상세 조회 오류", e);
            rtnMap.put("rtnCode", "ERROR");
            rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
        }
        return rtnMap;
    }

    /**
     * 배송정보(택배사/송장번호) 등록 AJAX
     */
    @RequestMapping("/saveOrdDelvInfo.do")
    @ResponseBody
    public HashMap<String, Object> saveOrdDelvInfo(@RequestParam String ordNo,
                                                   @RequestParam String delvCoCd,
                                                   @RequestParam String invoiceNo) {
        HashMap<String, Object> rtnMap = new HashMap<String, Object>();
        try {
            if (delvCoCd == null || "".equals(delvCoCd)) {
                rtnMap.put("rtnCode", "FAIL");
                rtnMap.put("rtnMsg", "택배사를 선택해주세요.");
                return rtnMap;
            }
            if (invoiceNo == null || "".equals(invoiceNo.trim())) {
                rtnMap.put("rtnCode", "FAIL");
                rtnMap.put("rtnMsg", "송장번호를 입력해주세요.");
                return rtnMap;
            }

            HashMap<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("ordNo", ordNo);
            paramMap.put("delvCoCd", delvCoCd);
            paramMap.put("invoiceNo", invoiceNo.trim());

            rtnMap = ordMngService.saveOrdDelvInfoTx(paramMap);

        } catch (Exception e) {
            logger.error("배송정보 등록 오류", e);
            rtnMap.put("rtnCode", "ERROR");
            rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
        }
        return rtnMap;
    }

    /**
     * 주문 상태 변경 AJAX
     */
    @RequestMapping("/updateOrdStat.do")
    @ResponseBody
    public HashMap<String, Object> updateOrdStat(@RequestParam String ordNo,
                                                @RequestParam String ordStatCd) {
        HashMap<String, Object> rtnMap = new HashMap<String, Object>();
        try {
            HashMap<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("ordNo", ordNo);
            paramMap.put("ordStatCd", ordStatCd);
            rtnMap = ordMngService.updateOrdStatTx(paramMap);
        } catch (Exception e) {
            logger.error("주문 상태 변경 오류", e);
            rtnMap.put("rtnCode", "ERROR");
            rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
        }
        return rtnMap;
    }
}
