package com.commerce.ec.dp.main.service;

import java.util.HashMap;
import java.util.List;

public interface MainService {
	List<HashMap<String, Object>> selectCategoryList() throws Exception;
	List<HashMap<String, Object>> selectNewPrdList() throws Exception;
}