package com.commerce.ec.mb.join.web;

import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.commerce.ec.mb.join.service.JoinService;
import com.commerce.ec.mb.join.service.JoinUserVO;

@Controller
@RequestMapping("/mb/join")
public class JoinController {

	private static final Logger logger = LoggerFactory.getLogger(JoinController.class);

	@Resource(name = "joinService")
	private JoinService joinService;

	/**
	 * 약관동의 페이지
	 */
	@RequestMapping("/joinAgree.do")
	public String joinAgree(ModelMap model) {
		return "mb/join/joinAgree.join";
	}

	/**
	 * 회원정보 입력 페이지
	 */
	@RequestMapping("/joinInput.do")
	public String joinInput(@RequestParam(value = "agreeYn", required = false) String agreeYn,
							@RequestParam(value = "privacyYn", required = false) String privacyYn,
							ModelMap model) {
		// 약관동의 체크 (컨트롤러에 검증 로직 - 레거시 패턴)
		if (!"Y".equals(agreeYn) || !"Y".equals(privacyYn)) {
			model.addAttribute("msg", "약관에 동의해주세요.");
			return "mb/join/joinAgree.join";
		}
		model.addAttribute("agreeYn", agreeYn);
		model.addAttribute("privacyYn", privacyYn);
		return "mb/join/joinInput.join";
	}

	/**
	 * 아이디 중복 체크
	 */
	@RequestMapping("/dupIdCheck.do")
	@ResponseBody
	public HashMap<String, Object> dupIdCheck(@RequestParam HashMap<String, Object> paramMap) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			int dupCnt = joinService.selectDupIdCheck(paramMap);
			if (dupCnt > 0) {
				rtnMap.put("rtnCode", "DUP");
				rtnMap.put("rtnMsg", "이미 사용중인 아이디입니다.");
			} else {
				rtnMap.put("rtnCode", "OK");
				rtnMap.put("rtnMsg", "사용 가능한 아이디입니다.");
			}
		} catch (Exception e) {
			e.printStackTrace();
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 회원가입 처리
	 */
	@RequestMapping("/saveJoinMbr.do")
	@ResponseBody
	public HashMap<String, Object> saveJoinMbr(JoinUserVO joinUserVO) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();
		try {
			// 컨트롤러에서 유효성 검증 (레거시 패턴 - Fat Controller)
			if (joinUserVO.getLoginId() == null || "".equals(joinUserVO.getLoginId())) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "아이디를 입력해주세요.");
				return rtnMap;
			}
			if (joinUserVO.getPwd() == null || "".equals(joinUserVO.getPwd())) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "비밀번호를 입력해주세요.");
				return rtnMap;
			}
			if (joinUserVO.getMbrNm() == null || "".equals(joinUserVO.getMbrNm())) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "이름을 입력해주세요.");
				return rtnMap;
			}
			if (!joinUserVO.getPwd().equals(joinUserVO.getPwdConfirm())) {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", "비밀번호가 일치하지 않습니다.");
				return rtnMap;
			}

			rtnMap = joinService.saveJoinMbrTx(joinUserVO);

		} catch (Exception e) {
			e.printStackTrace();
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "시스템 오류가 발생했습니다.");
		}
		return rtnMap;
	}

	/**
	 * 가입 완료 페이지
	 */
	@RequestMapping("/joinComplete.do")
	public String joinComplete(ModelMap model) {
		return "mb/join/joinComplete.join";
	}
}