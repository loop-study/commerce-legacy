package com.commerce.ec.mb.join.service.impl;

import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.commerce.ec.cmmn.utils.SHA256Util;
import com.commerce.ec.mb.join.service.JoinService;
import com.commerce.ec.mb.join.service.JoinUserVO;

@Service("joinService")
public class JoinServiceImpl implements JoinService {

	private static final Logger logger = LoggerFactory.getLogger(JoinServiceImpl.class);

	@Resource(name = "joinMapper")
	private JoinMapper joinMapper;

	@Override
	public HashMap<String, Object> saveJoinMbrTx(JoinUserVO joinUserVO) throws Exception {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		try {
			// 아이디 중복 체크
			HashMap<String, Object> dupMap = new HashMap<String, Object>();
			dupMap.put("loginId", joinUserVO.getLoginId());
			int dupCnt = joinMapper.selectDupIdCheck(dupMap);
			if (dupCnt > 0) {
				rtnMap.put("rtnCode", "DUP");
				rtnMap.put("rtnMsg", "이미 사용중인 아이디입니다.");
				return rtnMap;
			}

			// 비밀번호 확인 체크 (컨트롤러에서도 하지만 서비스에서도 중복 체크 - 레거시 패턴)
			if (!joinUserVO.getPwd().equals(joinUserVO.getPwdConfirm())) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "비밀번호가 일치하지 않습니다.");
				return rtnMap;
			}

			// 회원번호 채번
			String maxMbrNo = joinMapper.selectMaxMbrNo();
			String newMbrNo = "";
			if (maxMbrNo == null || "".equals(maxMbrNo)) {
				newMbrNo = "M000000001";
			} else {
				int seq = Integer.parseInt(maxMbrNo.substring(1)) + 1;
				newMbrNo = "M" + String.format("%09d", seq);
			}
			joinUserVO.setMbrNo(newMbrNo);

			// 비밀번호 SHA-256 암호화
			joinUserVO.setPwd(SHA256Util.encrypt(joinUserVO.getPwd()));

			// 회원 등록
			int result = joinMapper.insertJoinMbr(joinUserVO);
			if (result > 0) {
				rtnMap.put("rtnCode", "SUCCESS");
				rtnMap.put("rtnMsg", "회원가입이 완료되었습니다.");
				rtnMap.put("mbrNo", newMbrNo);
				logger.info("회원가입 완료 - " + joinUserVO.getLoginId() + " (" + newMbrNo + ")");
			} else {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "회원가입에 실패했습니다.");
			}

			// 원본에는 여기서 쿠폰 발급, 이메일 발송, 알림톡 등이 있었으나 제거

		} catch (Exception e) {
			e.printStackTrace();
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}

		return rtnMap;
	}

	@Override
	public int selectDupIdCheck(HashMap<String, Object> paramMap) throws Exception {
		return joinMapper.selectDupIdCheck(paramMap);
	}
}