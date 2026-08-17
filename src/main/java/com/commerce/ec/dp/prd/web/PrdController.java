package com.commerce.ec.dp.prd.web;

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

import com.commerce.ec.cmmn.utils.PagingUtil;
import com.commerce.ec.dp.prd.service.PrdService;


@Controller
@RequestMapping("/dp/good")
public class PrdController {

	private static final Logger logger = LoggerFactory.getLogger(PrdController.class);

	@Resource(name = "prdService")
	private PrdService prdService;

	/**
	 * 상품 목록 페이지
	 */
	@RequestMapping("/prdList.do")
	public String prdList(@RequestParam(required = false) String lCatCd,
						  @RequestParam(required = false) String mCatCd,
						  @RequestParam(required = false) String sCatCd,
						  @RequestParam(required = false) String searchKeyword,
						  @RequestParam(required = false) String sortTp,
						  @RequestParam(defaultValue = "1") int pageNo,
						  ModelMap model) {
		try {
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("lCatCd", lCatCd);
			paramMap.put("mCatCd", mCatCd);
			paramMap.put("sCatCd", sCatCd);
			paramMap.put("searchKeyword", searchKeyword);
			paramMap.put("sortTp", sortTp);

			// 총 건수 조회
			int totalCnt = prdService.selectPrdListCnt(paramMap);

			// 페이징 처리
			paramMap.put("pageNo", pageNo);
			paramMap.put("pageSize", 12);
			paramMap.put("totalCnt", totalCnt);
			PagingUtil.setPagingMap(paramMap);

			// 상품 목록 조회
			List<HashMap<String, Object>> prdList = prdService.selectPrdList(paramMap);

			// 대카테고리 목록 (필터용)
			List<HashMap<String, Object>> catList = prdService.selectCategoryList();

			// 중카테고리 목록 (선택된 대카테고리가 있을 경우)
			if (lCatCd != null && !lCatCd.isEmpty()) {
				List<HashMap<String, Object>> mCatList = prdService.selectSubCategoryList(lCatCd);
				model.addAttribute("mCatList", mCatList);
			}

			// 소카테고리 목록 (선택된 중카테고리가 있을 경우)
			if (mCatCd != null && !mCatCd.isEmpty()) {
				List<HashMap<String, Object>> sCatList = prdService.selectSubCategoryList(mCatCd);
				model.addAttribute("sCatList", sCatList);
			}

			model.addAttribute("prdList", prdList);
			model.addAttribute("catList", catList);
			model.addAttribute("totalCnt", totalCnt);
			model.addAttribute("pageNo", paramMap.get("pageNo"));
			model.addAttribute("startPage", paramMap.get("startPage"));
			model.addAttribute("endPage", paramMap.get("endPage"));
			model.addAttribute("prevPage", paramMap.get("prevPage"));
			model.addAttribute("nextPage", paramMap.get("nextPage"));
			model.addAttribute("totalPage", paramMap.get("totalPage"));
			model.addAttribute("lCatCd", lCatCd);
			model.addAttribute("mCatCd", mCatCd);
			model.addAttribute("sCatCd", sCatCd);
			model.addAttribute("searchKeyword", searchKeyword);
			model.addAttribute("sortTp", sortTp);

		} catch (Exception e) {
			logger.error("상품 목록 조회 오류", e);
		}
		return "dp/good/prdList.main";
	}

	/**
	 * 상품 목록 AJAX 조회
	 */
	@RequestMapping("/selectPrdListAjax.do")
	@ResponseBody
	public HashMap<String, Object> selectPrdListAjax(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			int totalCnt = prdService.selectPrdListCnt(paramMap);
			paramMap.put("pageSize", 12);
			paramMap.put("totalCnt", totalCnt);
			PagingUtil.setPagingMap(paramMap);

			List<HashMap<String, Object>> prdList = prdService.selectPrdList(paramMap);

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("prdList", prdList);
			rtnMap.put("totalCnt", totalCnt);
			rtnMap.put("pageNo", paramMap.get("pageNo"));
		} catch (Exception e) {
			logger.error("상품 목록 AJAX 조회 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 상품 상세 페이지
	 */
	@RequestMapping("/prdDtl.do")
	public String prdDtl(@RequestParam String prdCd, ModelMap model) {
		try {
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("prdCd", prdCd);

			// 상품 기본정보 + 가격 + 카테고리명
			HashMap<String, Object> prdInfo = prdService.selectPrdDtlInfo(paramMap);

			// 상품 이미지 목록
			List<HashMap<String, Object>> imgList = prdService.selectPrdImgList(paramMap);

			model.addAttribute("prdInfo", prdInfo);
			model.addAttribute("imgList", imgList);

		} catch (Exception e) {
			logger.error("상품 상세 조회 오류", e);
		}
		return "dp/good/prdDtl.main";
	}
}