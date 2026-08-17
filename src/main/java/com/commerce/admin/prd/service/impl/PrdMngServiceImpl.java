package com.commerce.admin.prd.service.impl;

import java.io.File;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.commerce.admin.prd.service.PrdMngService;
import com.commerce.admin.prd.service.PrdRegVO;

@Service("prdMngService")
public class PrdMngServiceImpl implements PrdMngService {

	private static final Logger logger = LoggerFactory.getLogger(PrdMngServiceImpl.class);

	@Resource(name = "prdMngMapper")
	private PrdMngMapper prdMngMapper;

	@Override
	public List<HashMap<String, Object>> selectPrdMngList(HashMap<String, Object> paramMap) throws Exception {
		return prdMngMapper.selectPrdMngList(paramMap);
	}

	@Override
	public int selectPrdMngListCnt(HashMap<String, Object> paramMap) throws Exception {
		return prdMngMapper.selectPrdMngListCnt(paramMap);
	}

	@Override
	public PrdRegVO selectPrdMngDtl(HashMap<String, Object> paramMap) throws Exception {
		return prdMngMapper.selectPrdMngDtl(paramMap);
	}

	@Override
	public List<HashMap<String, Object>> selectCategoryByLevel(int catLvl) throws Exception {
		return prdMngMapper.selectCategoryByLevel(catLvl);
	}

	@Override
	public List<HashMap<String, Object>> selectSubCategoryList(String upCatCd) throws Exception {
		return prdMngMapper.selectSubCategoryList(upCatCd);
	}

	@Override
	public List<HashMap<String, Object>> selectPrdDtlImgList(String prdCd) throws Exception {
		return prdMngMapper.selectPrdDtlImgList(prdCd);
	}

	@Override
	public HashMap<String, Object> savePrdTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		String mode = (String) paramMap.get("mode");

		// 필수값 체크
		if (paramMap.get("prdNm") == null || "".equals(paramMap.get("prdNm"))) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "상품명은 필수입니다.");
			return rtnMap;
		}

		// HashMap → PrdRegVO 변환
		PrdRegVO prdRegVO = new PrdRegVO();
		prdRegVO.setPrdNm((String) paramMap.get("prdNm"));
		prdRegVO.setSmplDesc((String) paramMap.get("smplDesc"));
		prdRegVO.setPrdStatCd((String) paramMap.get("prdStatCd"));
		prdRegVO.setDelvTpCd((String) paramMap.get("delvTpCd"));
		prdRegVO.setLCatCd((String) paramMap.get("lCatCd"));
		prdRegVO.setMCatCd((String) paramMap.get("mCatCd"));
		prdRegVO.setSCatCd((String) paramMap.get("sCatCd"));
		prdRegVO.setStockQty(toInt(paramMap.get("stockQty")));
		prdRegVO.setSalePrc(toLong(paramMap.get("salePrc")));
		prdRegVO.setCardDiscPrc(toLong(paramMap.get("cardDiscPrc")));
		prdRegVO.setCashDiscPrc(toLong(paramMap.get("cashDiscPrc")));

		if ("edit".equals(mode)) {
			// 수정
			prdRegVO.setPrdCd((String) paramMap.get("prdCd"));
			prdMngMapper.updatePrdMst(prdRegVO);
			prdMngMapper.updatePrdPrc(prdRegVO);

			// 새 이미지 업로드 시 기존 이미지 삭제 후 재등록
			saveImgFile(paramMap, prdRegVO);
			if (prdRegVO.getImgPath() != null && !prdRegVO.getImgPath().isEmpty()) {
				prdMngMapper.deletePrdImg(prdRegVO.getPrdCd());
				prdMngMapper.insertPrdImg(prdRegVO);
			}
			saveDtlImgFile(paramMap, prdRegVO);
			rtnMap.put("rtnMsg", "상품이 수정되었습니다.");
		} else {
			// 등록 - 상품코드 생성
			String maxPrdCd = prdMngMapper.selectMaxPrdCd();
			String prdCd;
			if (maxPrdCd == null) {
				prdCd = "P000000001";
			} else {
				int seq = Integer.parseInt(maxPrdCd.substring(1)) + 1;
				prdCd = "P" + String.format("%09d", seq);
			}
			prdRegVO.setPrdCd(prdCd);

			prdMngMapper.insertPrdMst(prdRegVO);
			prdMngMapper.insertPrdPrc(prdRegVO);

			// 이미지 등록
			saveImgFile(paramMap, prdRegVO);
			if (prdRegVO.getImgPath() != null && !prdRegVO.getImgPath().isEmpty()) {
				prdMngMapper.insertPrdImg(prdRegVO);
			}
			saveDtlImgFile(paramMap, prdRegVO);
			rtnMap.put("rtnMsg", "상품이 등록되었습니다.");
		}

		rtnMap.put("rtnCode", "SUCCESS");
		rtnMap.put("prdCd", prdRegVO.getPrdCd());
		return rtnMap;
	}

	/**
	 * 업로드된 이미지 파일을 저장하고 prdRegVO에 imgPath/imgName 세팅
	 * 파일명: {PRD_CD}_1.{ext}, 저장경로: prdimg/{lCatCd}/
	 */
	private void saveImgFile(HashMap<String, Object> paramMap, PrdRegVO prdRegVO) {
		MultipartFile imgFile = (MultipartFile) paramMap.get("imgFile");
		String uploadBase = (String) paramMap.get("uploadBase");
		if (imgFile == null || imgFile.isEmpty() || uploadBase == null) return;

		String lCatCd = prdRegVO.getLCatCd();
		if (lCatCd == null || lCatCd.isEmpty()) lCatCd = "COMMON";

		String originalName = imgFile.getOriginalFilename();
		String ext = "";
		if (originalName != null && originalName.lastIndexOf('.') >= 0) {
			ext = originalName.substring(originalName.lastIndexOf('.')).toLowerCase();
		}

		String imgName = prdRegVO.getPrdCd() + "_1" + ext;
		String imgPath = "/upload/" + lCatCd + "/" + imgName;

		File dir = new File(uploadBase + File.separator + lCatCd);
		if (!dir.exists()) dir.mkdirs();

		try {
			imgFile.transferTo(new File(dir, imgName));
			prdRegVO.setImgPath(imgPath);
			prdRegVO.setImgName(imgName);
		} catch (Exception e) {
			logger.error("이미지 파일 저장 오류: " + imgName, e);
		}
	}

	/**
	 * 상세이미지(IMG_TP_CD 20) 저장 - 여러 장
	 * 파일명: {PRD_CD}_D{순번}.{ext}, 저장경로: prdimg/{lCatCd}/
	 * 새로 올린 경우에만 기존 상세이미지를 지우고 재등록
	 */
	private void saveDtlImgFile(HashMap<String, Object> paramMap, PrdRegVO prdRegVO) {
		MultipartFile[] dtlImgFiles = (MultipartFile[]) paramMap.get("dtlImgFiles");
		String uploadBase = (String) paramMap.get("uploadBase");
		if (dtlImgFiles == null || dtlImgFiles.length == 0 || uploadBase == null) return;

		String lCatCd = prdRegVO.getLCatCd();
		if (lCatCd == null || lCatCd.isEmpty()) lCatCd = "COMMON";

		File dir = new File(uploadBase + File.separator + lCatCd);
		if (!dir.exists()) dir.mkdirs();

		int sortSeq = 0;
		for (int i = 0; i < dtlImgFiles.length; i++) {
			MultipartFile dtlImgFile = dtlImgFiles[i];
			if (dtlImgFile == null || dtlImgFile.isEmpty()) continue;

			sortSeq++;

			String originalName = dtlImgFile.getOriginalFilename();
			String ext = "";
			if (originalName != null && originalName.lastIndexOf('.') >= 0) {
				ext = originalName.substring(originalName.lastIndexOf('.')).toLowerCase();
			}

			String imgName = prdRegVO.getPrdCd() + "_D" + sortSeq + ext;
			String imgPath = "/upload/" + lCatCd + "/" + imgName;

			try {
				dtlImgFile.transferTo(new File(dir, imgName));

				// 첫 파일 저장 시점에 기존 상세이미지 정리
				if (sortSeq == 1) {
					prdMngMapper.deletePrdDtlImg(prdRegVO.getPrdCd());
				}

				HashMap<String, Object> imgMap = new HashMap<String, Object>();
				imgMap.put("prdCd", prdRegVO.getPrdCd());
				imgMap.put("imgPath", imgPath);
				imgMap.put("imgName", imgName);
				imgMap.put("sortSeq", sortSeq);
				prdMngMapper.insertPrdDtlImg(imgMap);

			} catch (Exception e) {
				logger.error("상세이미지 파일 저장 오류: " + imgName, e);
			}
		}
	}

	private long toLong(Object val) {
		if (val == null) return 0L;
		if (val instanceof Number) return ((Number) val).longValue();
		try { return Long.parseLong(val.toString().trim()); } catch (NumberFormatException e) { return 0L; }
	}

	private int toInt(Object val) {
		if (val == null) return 0;
		if (val instanceof Number) return ((Number) val).intValue();
		try { return Integer.parseInt(val.toString().trim()); } catch (NumberFormatException e) { return 0; }
	}

	@Override
	public HashMap<String, Object> updatePrdStatTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		prdMngMapper.updatePrdStat(paramMap);
		rtnMap.put("rtnCode", "SUCCESS");
		rtnMap.put("rtnMsg", "상품 상태가 변경되었습니다.");
		return rtnMap;
	}
}
