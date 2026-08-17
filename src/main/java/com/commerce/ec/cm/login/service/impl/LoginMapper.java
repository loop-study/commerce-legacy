package com.commerce.ec.cm.login.service.impl;

import java.util.HashMap;

import com.commerce.ec.cm.login.service.MemberVO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface LoginMapper {
	HashMap<String, Object> selectMbrLoginInfo(HashMap<String, Object> paramMap);
	int updateLoginFailCnt(HashMap<String, Object> paramMap);
	int resetLoginFailCnt(HashMap<String, Object> paramMap);
}