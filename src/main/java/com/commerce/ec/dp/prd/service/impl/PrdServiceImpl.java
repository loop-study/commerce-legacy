package com.commerce.ec.dp.prd.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.ec.dp.prd.service.PrdService;

@Service("prdService")
public class PrdServiceImpl implements PrdService {

	private static final Logger logger = LoggerFactory.getLogger(PrdServiceImpl.class);

	@Resource(name = "prdMapper")
	private PrdMapper prdMapper;

	@Override
	public List<HashMap<String, Object>> selectPrdList(HashMap<String, Object> paramMap) throws Exception {
		return prdMapper.selectPrdList(paramMap);
	}

	@Override
	public int selectPrdListCnt(HashMap<String, Object> paramMap) throws Exception {
		return prdMapper.selectPrdListCnt(paramMap);
	}

	@Override
	public HashMap<String, Object> selectPrdDtlInfo(HashMap<String, Object> paramMap) throws Exception {
		return prdMapper.selectPrdDtlInfo(paramMap);
	}

	@Override
	public List<HashMap<String, Object>> selectPrdImgList(HashMap<String, Object> paramMap) throws Exception {
		return prdMapper.selectPrdImgList(paramMap);
	}

	@Override
	public List<HashMap<String, Object>> selectCategoryList() throws Exception {
		return prdMapper.selectCategoryList();
	}

	@Override
	public List<HashMap<String, Object>> selectSubCategoryList(String upCatCd) throws Exception {
		return prdMapper.selectSubCategoryList(upCatCd);
	}
}