package com.commerce.admin.prd.web;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.commerce.ec.cmmn.utils.PagingUtil;
import com.commerce.admin.prd.service.PrdMngService;
import com.commerce.admin.prd.service.PrdRegVO;

@Controller
@RequestMapping("/admin/gd")
public class PrdMngController {

	private static final Logger logger = LoggerFactory.getLogger(PrdMngController.class);

	@Resource(name = "prdMngService")
	private PrdMngService prdMngService;

	/**
	 * 상품 관리 목록 페이지
	 */
	@RequestMapping("/prdMng.do")
	public String prdMng(@RequestParam(defaultValue = "1") int pageNo,
						 @RequestParam(required = false) String searchKeyword,
						 @RequestParam(required = false) String prdStatCd,
						 ModelMap model) {
		try {
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("searchKeyword", searchKeyword);
			paramMap.put("prdStatCd", prdStatCd);

			// 총 건수
			int totalCnt = prdMngService.selectPrdMngListCnt(paramMap);

			// 페이징
			paramMap.put("pageNo", pageNo);
			paramMap.put("pageSize", 10);
			paramMap.put("totalCnt", totalCnt);
			PagingUtil.setPagingMap(paramMap);

			// 상품 목록
			List<HashMap<String, Object>> prdList = prdMngService.selectPrdMngList(paramMap);

			model.addAttribute("prdList", prdList);
			model.addAttribute("totalCnt", totalCnt);
			model.addAttribute("pageNo", paramMap.get("pageNo"));
			model.addAttribute("startPage", paramMap.get("startPage"));
			model.addAttribute("endPage", paramMap.get("endPage"));
			model.addAttribute("prevPage", paramMap.get("prevPage"));
			model.addAttribute("nextPage", paramMap.get("nextPage"));
			model.addAttribute("totalPage", paramMap.get("totalPage"));
			model.addAttribute("searchKeyword", searchKeyword);
			model.addAttribute("prdStatCd", prdStatCd);

		} catch (Exception e) {
			logger.error("상품 관리 목록 조회 오류", e);
		}
		return "gd/prdMng.admin";
	}

	/**
	 * 상품 등록/수정 폼 페이지
	 */
	@RequestMapping("/prdReg.do")
	public String prdReg(@RequestParam(required = false) String prdCd, ModelMap model) {
		try {
			// 카테고리 목록 (대/중/소)
			List<HashMap<String, Object>> lCatList = prdMngService.selectCategoryByLevel(1);
			model.addAttribute("lCatList", lCatList);

			// 수정인 경우 상품 정보 조회
			if (prdCd != null && !prdCd.isEmpty()) {
				HashMap<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("prdCd", prdCd);
				PrdRegVO prdInfo = prdMngService.selectPrdMngDtl(paramMap);
				model.addAttribute("prdInfo", prdInfo);
				model.addAttribute("mode", "edit");

				// 선택된 대카테고리의 중카테고리
				if (prdInfo != null && prdInfo.getLCatCd() != null) {
					List<HashMap<String, Object>> mCatList = prdMngService.selectSubCategoryList(prdInfo.getLCatCd());
					model.addAttribute("mCatList", mCatList);
				}
				// 선택된 중카테고리의 소카테고리
				if (prdInfo != null && prdInfo.getMCatCd() != null) {
					List<HashMap<String, Object>> sCatList = prdMngService.selectSubCategoryList(prdInfo.getMCatCd());
					model.addAttribute("sCatList", sCatList);
				}

				// 등록된 상세이미지 목록
				model.addAttribute("dtlImgList", prdMngService.selectPrdDtlImgList(prdCd));
			} else {
				model.addAttribute("mode", "new");
			}
		} catch (Exception e) {
			logger.error("상품 등록/수정 폼 오류", e);
		}
		return "gd/prdReg.admin";
	}

	/**
	 * 하위 카테고리 AJAX 조회
	 */
	@RequestMapping("/selectSubCatList.do")
	@ResponseBody
	public HashMap<String, Object> selectSubCatList(@RequestParam String upCatCd) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			List<HashMap<String, Object>> catList = prdMngService.selectSubCategoryList(upCatCd);
			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("catList", catList);
		} catch (Exception e) {
			rtnMap.put("rtnCode", "ERROR");
		}
		return rtnMap;
	}

	/**
	 * 상품 저장 (등록/수정)
	 */
	@RequestMapping("/savePrd.do")
	@ResponseBody
	public HashMap<String, Object> savePrd(
			@RequestParam HashMap<String, Object> paramMap,
			@RequestParam(value = "imgFile", required = false) MultipartFile imgFile,
			@RequestParam(value = "dtlImgFiles", required = false) MultipartFile[] dtlImgFiles,
			HttpServletRequest request) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			// 판매가 / 카드할인가 / 현금할인가는 모두 필수
			if (isEmptyPrc(paramMap.get("salePrc"))) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "판매가를 입력해주세요.");
				return rtnMap;
			}
			if (isEmptyPrc(paramMap.get("cardDiscPrc"))) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "카드할인가를 입력해주세요.");
				return rtnMap;
			}
			if (isEmptyPrc(paramMap.get("cashDiscPrc"))) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "현금할인가를 입력해주세요.");
				return rtnMap;
			}

			// 대/중/소 카테고리는 모두 필수
			if (isEmptyPrc(paramMap.get("lCatCd"))) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "대카테고리를 선택해주세요.");
				return rtnMap;
			}
			if (isEmptyPrc(paramMap.get("mCatCd"))) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "중카테고리를 선택해주세요.");
				return rtnMap;
			}
			if (isEmptyPrc(paramMap.get("sCatCd"))) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "소카테고리를 선택해주세요.");
				return rtnMap;
			}

			if (imgFile != null && !imgFile.isEmpty()) {
				paramMap.put("imgFile", imgFile);
			}
			if (dtlImgFiles != null && dtlImgFiles.length > 0) {
				paramMap.put("dtlImgFiles", dtlImgFiles);
			}
			if (paramMap.get("imgFile") != null || paramMap.get("dtlImgFiles") != null) {
				paramMap.put("uploadBase", request.getServletContext().getRealPath("/upload"));
			}
			rtnMap = prdMngService.savePrdTx(paramMap);
		} catch (Exception e) {
			logger.error("상품 저장 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 상품 삭제 (상태 변경 - 판매종료)
	 */
	@RequestMapping("/deletePrd.do")
	@ResponseBody
	public HashMap<String, Object> deletePrd(@RequestParam String prdCd) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			HashMap<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("prdCd", prdCd);
			paramMap.put("prdStatCd", "90");
			rtnMap = prdMngService.updatePrdStatTx(paramMap);
		} catch (Exception e) {
			logger.error("상품 삭제 오류", e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/** 필수값 미입력 체크 */
	private boolean isEmptyPrc(Object val) {
		return val == null || "".equals(val.toString().trim());
	}
}
