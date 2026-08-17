package com.commerce.admin.prd.web;

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

import com.commerce.admin.prd.service.CatMngService;

@Controller
@RequestMapping("/admin/gd")
public class CatMngController {

	private static final Logger logger = LoggerFactory.getLogger(CatMngController.class);

	@Resource(name = "catMngService")
	private CatMngService catMngService;

	/**
	 * 카테고리 관리 페이지 (대/중/소 3단 드릴다운)
	 */
	@RequestMapping("/catMng.do")
	public String catMng(@RequestParam(required = false) String lCatCd,
						 @RequestParam(required = false) String mCatCd,
						 ModelMap model) {
		try {
			// 대분류
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("catLvl", 1);
			model.addAttribute("lCatList", catMngService.selectCatMngList(paramMap));

			// 중분류 (대분류 선택 시)
			if (lCatCd != null && !"".equals(lCatCd)) {
				paramMap = new HashMap<String, Object>();
				paramMap.put("catLvl", 2);
				paramMap.put("upCatCd", lCatCd);
				model.addAttribute("mCatList", catMngService.selectCatMngList(paramMap));
			}

			// 소분류 (중분류 선택 시)
			if (mCatCd != null && !"".equals(mCatCd)) {
				paramMap = new HashMap<String, Object>();
				paramMap.put("catLvl", 3);
				paramMap.put("upCatCd", mCatCd);
				model.addAttribute("sCatList", catMngService.selectCatMngList(paramMap));
			}

			model.addAttribute("lCatCd", lCatCd);
			model.addAttribute("mCatCd", mCatCd);

		} catch (Exception e) {
			logger.error("카테고리 관리 조회 오류", e);
		}
		return "gd/catMng.admin";
	}

	/**
	 * 카테고리 등록/수정 AJAX
	 */
	@RequestMapping("/saveCat.do")
	@ResponseBody
	public HashMap<String, Object> saveCat(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			String catNm = (String) paramMap.get("catNm");
			if (catNm == null || "".equals(catNm.trim())) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "카테고리명을 입력해주세요.");
				return rtnMap;
			}
			paramMap.put("catNm", catNm.trim());

			// 정렬순서 / 사용여부 기본값
			if (paramMap.get("sortSeq") == null || "".equals(paramMap.get("sortSeq"))) {
				paramMap.put("sortSeq", "0");
			}
			if (paramMap.get("useYn") == null || "".equals(paramMap.get("useYn"))) {
				paramMap.put("useYn", "Y");
			}

			rtnMap = catMngService.saveCatTx(paramMap);

		} catch (Exception e) {
			logger.error("카테고리 저장 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 카테고리 삭제 AJAX
	 */
	@RequestMapping("/deleteCat.do")
	@ResponseBody
	public HashMap<String, Object> deleteCat(@RequestParam String catCd) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("catCd", catCd);
			rtnMap = catMngService.deleteCatTx(paramMap);
		} catch (Exception e) {
			logger.error("카테고리 삭제 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 카테고리 단건 조회 AJAX (수정 모달용)
	 */
	@RequestMapping("/selectCatDtl.do")
	@ResponseBody
	public HashMap<String, Object> selectCatDtl(@RequestParam String catCd) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			HashMap<String, Object> catInfo = catMngService.selectCatMngDtl(catCd);
			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("catInfo", catInfo);
		} catch (Exception e) {
			logger.error("카테고리 상세 조회 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}
}
