package com.commerce.ec.cmmn.web;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.commerce.ec.cmmn.CmmnMessage;
import com.commerce.ec.cmmn.utils.NumberUtil;

/**
 * 모의 PG 서버
 *
 * 실제 외부 PG사를 호출할 수 없으므로 같은 애플리케이션 안에 응답만 흉내내는 엔드포인트를 둔다.
 * 호출부(PgApiUtil)는 실제 외부 연동과 동일하게 HTTP 로 접근한다.
 *
 * 동작 제어 : message-common.properties
 *  - pg.mock.delay   : 응답 지연(ms)  → 지연 장애 시연
 *  - pg.mock.fail.yn : Y 이면 승인 거절 → 승인 실패 시연
 */
@Controller
@RequestMapping("/mock/pg")
public class MockPgController {

	private static final Logger logger = LoggerFactory.getLogger(MockPgController.class);

	@Resource
	private CmmnMessage cmmnMessage;

	@RequestMapping("/approve.do")
	@ResponseBody
	public HashMap<String, Object> approve(@RequestParam String ordNo,
										   @RequestParam(required = false, defaultValue = "0") long payAmt) {
		HashMap<String, Object> resMap = new HashMap<String, Object>();

		// 응답 지연 주입
		int delay = toInt(cmmnMessage.getMessage("pg.mock.delay"));
		if (delay > 0) {
			logger.info("[MockPG] 응답 지연 " + delay + "ms - 주문번호:" + ordNo);
			try {
				Thread.sleep(delay);
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			}
		}

		// 승인 거절 주입
		String failYn = cmmnMessage.getMessage("pg.mock.fail.yn");
		if ("Y".equals(failYn)) {
			logger.info("[MockPG] 승인 거절 - 주문번호:" + ordNo);
			resMap.put("resultCd", "9001");
			resMap.put("resultMsg", "카드 승인이 거절되었습니다. (한도초과)");
			return resMap;
		}

		// 정상 승인
		String aprvNo = "PG" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())
						+ NumberUtil.randNumGenerate(4);
		resMap.put("resultCd", "0000");
		resMap.put("resultMsg", "정상 승인되었습니다.");
		resMap.put("aprvNo", aprvNo);
		resMap.put("aprvAmt", payAmt);
		logger.info("[MockPG] 승인 완료 - 주문번호:" + ordNo + " 승인번호:" + aprvNo);

		return resMap;
	}

	/**
	 * 승인 취소
	 *
	 * 승인은 났는데 그 뒤 주문 저장이 실패했을 때 호출한다.
	 * 승인만 남고 주문은 없는 상태를 되돌리기 위한 것이다.
	 */
	@RequestMapping("/cancel.do")
	@ResponseBody
	public HashMap<String, Object> cancel(@RequestParam String ordNo,
										  @RequestParam(required = false) String aprvNo) {
		HashMap<String, Object> resMap = new HashMap<String, Object>();

		// 취소 실패 주입
		String failYn = cmmnMessage.getMessage("pg.mock.cancel.fail.yn");
		if ("Y".equals(failYn)) {
			logger.info("[MockPG] 취소 거절 - 주문번호:" + ordNo + " 승인번호:" + aprvNo);
			resMap.put("resultCd", "9002");
			resMap.put("resultMsg", "승인 취소에 실패했습니다.");
			return resMap;
		}

		resMap.put("resultCd", "0000");
		resMap.put("resultMsg", "정상 취소되었습니다.");
		logger.info("[MockPG] 취소 완료 - 주문번호:" + ordNo + " 승인번호:" + aprvNo);

		return resMap;
	}

	private int toInt(Object val) {
		if (val == null) return 0;
		try { return Integer.parseInt(val.toString().trim()); } catch (NumberFormatException e) { return 0; }
	}
}
