package com.commerce.ec.dp.main.service.impl;

import org.apache.ibatis.annotations.Mapper;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface MainMapper {
	List<HashMap<String, Object>> selectCategoryList();
	List<HashMap<String, Object>> selectNewPrdList();
}