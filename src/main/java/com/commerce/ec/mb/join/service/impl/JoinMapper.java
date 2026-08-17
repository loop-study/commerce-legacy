package com.commerce.ec.mb.join.service.impl;

import java.util.HashMap;

import org.apache.ibatis.annotations.Mapper;

import com.commerce.ec.mb.join.service.JoinUserVO;

@Mapper
public interface JoinMapper {
	int insertJoinMbr(JoinUserVO joinUserVO);
	int selectDupIdCheck(HashMap<String, Object> paramMap);
	String selectMaxMbrNo();
}