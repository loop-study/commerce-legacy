package com.commerce.admin.cm.login.service.impl;

import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.admin.cm.login.service.AdminLoginService;
import com.commerce.admin.cm.login.service.AdminVO;
import com.commerce.ec.cmmn.utils.SHA256Util;
import com.commerce.ec.cmmn.utils.SessionUtil;

@Service("adminLoginService")
public class AdminLoginServiceImpl implements AdminLoginService {

	private static final Logger logger = LoggerFactory.getLogger(AdminLoginServiceImpl.class);

	@Resource(name = "adminLoginMapper")
	private AdminLoginMapper adminLoginMapper;

	@Override
	public HashMap<String, Object> adminLoginProcTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		HashMap<String, Object> adminInfo = adminLoginMapper.selectAdminLoginInfo(paramMap);

		if (adminInfo == null) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
			return rtnMap;
		}

		String inputPwd = SHA256Util.encrypt((String) paramMap.get("pwd"));
		String dbPwd = (String) adminInfo.get("pwd");
		if (!inputPwd.equals(dbPwd)) {
			rtnMap.put("rtnCode", "FAIL");
			rtnMap.put("rtnMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
			return rtnMap;
		}

		AdminVO adminVO = new AdminVO();
		adminVO.setAdminNo((String) adminInfo.get("adminNo"));
		adminVO.setAdminNm((String) adminInfo.get("adminNm"));
		adminVO.setLoginId((String) adminInfo.get("loginId"));

		SessionUtil.setData("adminVO", adminVO);

		logger.info("관리자 로그인 성공 - " + adminVO.getLoginId());

		rtnMap.put("rtnCode", "SUCCESS");
		rtnMap.put("rtnMsg", "로그인 성공");
		return rtnMap;
	}
}
