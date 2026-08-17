package com.commerce.ec.cmmn.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

// 당시 전자정부 egovMap을 사용하다보니 HashMap으로 변환하는 MapUtil을 사용했음.
// 매번 유틸로 egovMap <-> hashMap 변환, 비효율적인 과정. 보여주기위해 남김.
public class MapUtil {

	private static ObjectMapper objectMapper = new ObjectMapper();

	public static HashMap<String, Object> convertMap(Map<String, Object> map) {
		if (map == null) return new HashMap<String, Object>();
		return new HashMap<String, Object>(map);
	}

	public static List<HashMap<String, Object>> jsonToListMap(String json) {
		try {
			return objectMapper.readValue(json, new TypeReference<List<HashMap<String, Object>>>() {});
		} catch (Exception e) {
			e.printStackTrace();
			return new ArrayList<HashMap<String, Object>>();
		}
	}

	public static HashMap<String, Object> jsonToMap(String json) {
		try {
			return objectMapper.readValue(json, new TypeReference<HashMap<String, Object>>() {});
		} catch (Exception e) {
			e.printStackTrace();
			return new HashMap<String, Object>();
		}
	}
}
