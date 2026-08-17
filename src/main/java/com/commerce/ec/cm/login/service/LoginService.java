package com.commerce.ec.cm.login.service;

import java.util.HashMap;

public interface LoginService {
	HashMap<String, Object> loginProcTx(HashMap<String, Object> paramMap) throws Exception;
}