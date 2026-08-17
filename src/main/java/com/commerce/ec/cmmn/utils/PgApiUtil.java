package com.commerce.ec.cmmn.utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.commerce.ec.cmmn.CmmnMessage;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 카드결제 PG 승인 연동
 *
 * ※ 레거시 기술부채 (의도적으로 유지)
 *  - 주문 트랜잭션 안에서 동기 호출한다. PG 응답이 늦으면 DB 커넥션을 잡은 채로 대기한다.
 *  - 타임아웃이 pg.api.timeout=0(무제한)으로 설정되어 있다.
 *    PG가 느려지면 주문 스레드가 계속 쌓여 커넥션 풀이 고갈되고,
 *    주문과 무관한 화면까지 함께 멈추는 연쇄 장애로 번진다.
 *  - 재시도/폴백이 없어 PG 실패는 곧 주문 실패다.
 */
@Component
public class PgApiUtil {

	private static final Logger logger = LoggerFactory.getLogger(PgApiUtil.class);

	@Resource
	private CmmnMessage cmmnMessage;

	/**
	 * PG 승인 요청
	 * @return rtnCode(SUCCESS/FAIL/ERROR), rtnMsg, pgAprvNo
	 */
	public HashMap<String, Object> approve(String ordNo, long payAmt) {
		HashMap<String, Object> rtnMap = new HashMap<String, Object>();

		String apiUrl = cmmnMessage.getMessage("pg.api.url");

		try {
			StringBuilder param = new StringBuilder();
			param.append("ordNo=").append(URLEncoder.encode(ordNo, "UTF-8"));
			param.append("&payAmt=").append(payAmt);

			HashMap<String, Object> resMap = post(apiUrl, param.toString(), ordNo, "승인");

			if ("0000".equals(resMap.get("resultCd"))) {
				rtnMap.put("rtnCode", "SUCCESS");
				rtnMap.put("pgAprvNo", resMap.get("aprvNo"));
			} else {
				rtnMap.put("rtnCode", "FAIL");
				rtnMap.put("rtnMsg", (String) resMap.get("resultMsg"));
			}

		} catch (Exception e) {
			// 폴백 없음 - 호출부에서 주문 실패로 처리된다
			logger.error("PG 승인 연동 오류 - 주문번호:" + ordNo, e);
			rtnMap.put("rtnCode", "ERROR");
			rtnMap.put("rtnMsg", "결제 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
		}

		return rtnMap;
	}

	/**
	 * PG 승인 취소
	 *
	 * 승인을 받은 뒤 주문 저장이 실패했을 때 호출한다.
	 * 승인만 남고 주문은 없는 상태를 되돌리기 위한 것이다.
	 *
	 * ※ 레거시 기술부채 (의도적으로 유지)
	 *  - 취소 자체가 실패하면 로그만 남는다. 재시도도, 실패를 적어두는 곳도 없다.
	 *    그 경우 승인만 남은 주문을 사람이 찾아내 손으로 처리해야 한다.
	 *
	 * @return 취소 성공 여부
	 */
	public boolean cancel(String ordNo, String pgAprvNo) {
		String apiUrl = cmmnMessage.getMessage("pg.api.cancel.url");

		try {
			StringBuilder param = new StringBuilder();
			param.append("ordNo=").append(URLEncoder.encode(ordNo, "UTF-8"));
			if (pgAprvNo != null) {
				param.append("&aprvNo=").append(URLEncoder.encode(pgAprvNo, "UTF-8"));
			}

			HashMap<String, Object> resMap = post(apiUrl, param.toString(), ordNo, "취소");
			return "0000".equals(resMap.get("resultCd"));

		} catch (Exception e) {
			logger.error("PG 승인 취소 연동 오류 - 주문번호:" + ordNo + " 승인번호:" + pgAprvNo, e);
			return false;
		}
	}

	/** 승인·취소가 같은 방식으로 호출하므로 HTTP 부분만 따로 둔다. */
	private HashMap<String, Object> post(String apiUrl, String param, String ordNo, String action)
			throws Exception {

		int timeout = toInt(cmmnMessage.getMessage("pg.api.timeout"));

		HttpURLConnection conn = null;
		BufferedReader reader = null;
		long startTime = System.currentTimeMillis();

		try {
			conn = (HttpURLConnection) new URL(apiUrl).openConnection();
			conn.setRequestMethod("POST");
			conn.setDoOutput(true);
			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
			// 타임아웃 0 = 무제한 대기
			conn.setConnectTimeout(timeout);
			conn.setReadTimeout(timeout);

			OutputStream os = conn.getOutputStream();
			os.write(param.getBytes("UTF-8"));
			os.flush();
			os.close();

			StringBuilder response = new StringBuilder();
			reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
			String line;
			while ((line = reader.readLine()) != null) {
				response.append(line);
			}

			@SuppressWarnings("unchecked")
			HashMap<String, Object> resMap =
					new ObjectMapper().readValue(response.toString(), HashMap.class);

			long elapsed = System.currentTimeMillis() - startTime;
			logger.info("PG " + action + " 응답 - 주문번호:" + ordNo
					+ " 결과:" + resMap.get("resultCd") + " 소요:" + elapsed + "ms");

			return resMap;

		} finally {
			if (reader != null) {
				try { reader.close(); } catch (Exception e) { }
			}
			if (conn != null) {
				conn.disconnect();
			}
		}
	}

	private int toInt(Object val) {
		if (val == null) return 0;
		try { return Integer.parseInt(val.toString().trim()); } catch (NumberFormatException e) { return 0; }
	}
}
