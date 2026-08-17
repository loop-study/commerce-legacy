package com.commerce.admin.prd.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.admin.prd.service.CatMngService;

@Service("catMngService")
public class CatMngServiceImpl implements CatMngService {

	private static final Logger logger = LoggerFactory.getLogger(CatMngServiceImpl.class);

	@Resource(name = "catMngMapper")
	private CatMngMapper catMngMapper;

	@Override
	public List<HashMap<String, Object>> selectCatMngList(HashMap<String, Object> paramMap) throws Exception {
		return catMngMapper.selectCatMngList(paramMap);
	}

	@Override
	public HashMap<String, Object> selectCatMngDtl(String catCd) throws Exception {
		return catMngMapper.selectCatMngDtl(catCd);
	}

	/**
	 * 카테고리 등록/수정
	 * - 등록 시 카테고리코드 채번 : 대 L / 중 M / 소 S + 3자리
	 */
	@Override
	public HashMap<String, Object> saveCatTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		String mode = (String) paramMap.get("mode");

		if ("edit".equals(mode)) {
			catMngMapper.updateCat(paramMap);
			rtnMap.put("rtnMsg", "카테고리가 수정되었습니다.");
		} else {
			int catLvl = toInt(paramMap.get("catLvl"));

			// 카테고리코드 채번
			String prefix = "L";
			if (catLvl == 2) prefix = "M";
			else if (catLvl == 3) prefix = "S";

			String maxCatCd = catMngMapper.selectMaxCatCd(catLvl);
			String catCd;
			if (maxCatCd == null || "".equals(maxCatCd)) {
				catCd = prefix + "001";
			} else {
				int seq = Integer.parseInt(maxCatCd.substring(1)) + 1;
				catCd = prefix + String.format("%03d", seq);
			}
			paramMap.put("catCd", catCd);

			catMngMapper.insertCat(paramMap);
			rtnMap.put("catCd", catCd);
			rtnMap.put("rtnMsg", "카테고리가 등록되었습니다.");
			logger.info("카테고리 등록 - " + catCd + " (" + paramMap.get("catNm") + ")");
		}

		rtnMap.put("rtnCode", "SUCCESS");
		return rtnMap;
	}

	/**
	 * 카테고리 삭제
	 * - 하위 카테고리가 있거나 사용중인 상품이 있으면 삭제 불가
	 */
	@Override
	public HashMap<String, Object> deleteCatTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		String catCd = (String) paramMap.get("catCd");

		HashMap<String, Object> catInfo = catMngMapper.selectCatMngDtl(catCd);
		if (catInfo == null) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "존재하지 않는 카테고리입니다.");
			return rtnMap;
		}

		int subCatCnt = catMngMapper.selectSubCatCnt(catCd);
		if (subCatCnt > 0) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "하위 카테고리가 " + subCatCnt + "건 있어 삭제할 수 없습니다.");
			return rtnMap;
		}

		HashMap<String, Object> prdParam = new HashMap<String, Object>();
		prdParam.put("catCd", catCd);
		prdParam.put("catLvl", toInt(catInfo.get("catLvl")));
		int prdCnt = catMngMapper.selectCatPrdCnt(prdParam);
		if (prdCnt > 0) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "사용중인 상품이 " + prdCnt + "건 있어 삭제할 수 없습니다.");
			return rtnMap;
		}

		catMngMapper.deleteCat(catCd);

		rtnMap.put("rtnCode", "SUCCESS");
		rtnMap.put("rtnMsg", "카테고리가 삭제되었습니다.");
		return rtnMap;
	}

	private int toInt(Object val) {
		if (val == null) return 0;
		if (val instanceof Number) return ((Number) val).intValue();
		try { return Integer.parseInt(val.toString().trim()); } catch (NumberFormatException e) { return 0; }
	}
}
