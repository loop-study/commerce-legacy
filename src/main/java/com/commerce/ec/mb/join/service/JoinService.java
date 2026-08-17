package com.commerce.ec.mb.join.service;

import java.util.HashMap;

public interface JoinService {
	HashMap<String, Object> saveJoinMbrTx(JoinUserVO joinUserVO) throws Exception;
	int selectDupIdCheck(HashMap<String, Object> paramMap) throws Exception;
}