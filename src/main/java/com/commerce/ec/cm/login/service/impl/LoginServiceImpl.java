package com.commerce.ec.cm.login.service.impl;

import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.ec.cm.login.service.LoginService;
import com.commerce.ec.cm.login.service.MemberVO;
import com.commerce.ec.cmmn.utils.SHA256Util;
import com.commerce.ec.cmmn.utils.SessionUtil;

@Service("loginService")
public class LoginServiceImpl implements LoginService {

	private static final Logger logger = LoggerFactory.getLogger(LoginServiceImpl.class);

	@Resource(name = "loginMapper")
	private LoginMapper loginMapper;

	@Override
	public HashMap<String, Object> loginProcTx(HashMap<String, Object> paramMap) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		try {
			// 회원 정보 조회
			HashMap<String, Object> mbrInfo = loginMapper.selectMbrLoginInfo(paramMap);

			if (mbrInfo == null) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
				return rtnMap;
			}

			// 회원상태 체크 (매직스트링 - 레거시 패턴)
			String mbrStatCd = (String) mbrInfo.get("mbrStatCd");
			if ("20".equals(mbrStatCd)) {
				rtnMap.put("rtnCode", "DORMANT");
				rtnMap.put("rtnMsg", "휴면 상태의 계정입니다.");
				return rtnMap;
			}
			if ("30".equals(mbrStatCd)) {
				rtnMap.put("rtnCode", "WITHDRAW");
				rtnMap.put("rtnMsg", "탈퇴한 계정입니다.");
				return rtnMap;
			}
			if ("40".equals(mbrStatCd)) {
				rtnMap.put("rtnCode", "BLACKLIST");
				rtnMap.put("rtnMsg", "이용이 제한된 계정입니다.");
				return rtnMap;
			}

			// 비밀번호 SHA-256 해시 후 비교
			String inputPwd = SHA256Util.encrypt((String) paramMap.get("pwd"));
			String dbPwd = (String) mbrInfo.get("pwd");
			if (!inputPwd.equals(dbPwd)) {
				// 로그인 실패 횟수 증가
				loginMapper.updateLoginFailCnt(paramMap);
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
				return rtnMap;
			}

			// 로그인 성공 - 세션 생성
			MemberVO memberVO = new MemberVO();
			memberVO.setMbrNo((String) mbrInfo.get("mbrNo"));
			memberVO.setMbrNm((String) mbrInfo.get("mbrNm"));
			memberVO.setLoginId((String) mbrInfo.get("loginId"));
			memberVO.setMbrGrdCd((String) mbrInfo.get("mbrGrdCd"));
			if (mbrInfo.get("hpNo") != null) {
				memberVO.setHpNo((String) mbrInfo.get("hpNo"));
			}

			// 등급명 세팅 (매직스트링)
			// 현재는 일반 등급만 사용. 기획전/복지몰처럼 등급별 가격·노출 제어가 필요해지면 여기에 등급 추가
			String mbrGrdCd = (String) mbrInfo.get("mbrGrdCd");
			if ("10".equals(mbrGrdCd)) {
				memberVO.setMbrGrdNm("일반");
			}

			SessionUtil.setSessionData(memberVO);

			// 로그인 성공 - 실패 횟수 초기화
			loginMapper.resetLoginFailCnt(paramMap);

			rtnMap.put("rtnCode", "SUCCESS");
			rtnMap.put("rtnMsg", "로그인 성공");

			logger.info("로그인 성공 - " + memberVO.getLoginId());

		} catch (Exception e) {
			e.printStackTrace();
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}

		return rtnMap;
	}
}