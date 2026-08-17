package com.commerce.ec.dp.main.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.ec.dp.main.service.MainService;

@Service("mainService")
public class MainServiceImpl implements MainService {

	private static final Logger logger = LoggerFactory.getLogger(MainServiceImpl.class);

	@Resource(name = "mainMapper")
	private MainMapper mainMapper;

	@Override
	public List<HashMap<String, Object>> selectCategoryList() throws Exception {
		return mainMapper.selectCategoryList();
	}

	@Override
	public List<HashMap<String, Object>> selectNewPrdList() throws Exception {
		return mainMapper.selectNewPrdList();
	}
}