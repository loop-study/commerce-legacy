package com.commerce.admin.cm.login.service.impl;

import java.util.HashMap;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AdminLoginMapper {
	HashMap<String, Object> selectAdminLoginInfo(HashMap<String, Object> paramMap);
}
