package com.commerce.ec.cmmn.utils;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;

import org.junit.Test;

/**
 * PagingUtil 파라미터 검증
 *
 * ※ 이 테스트는 지금 전부 실패한다. 그것이 목적이다.
 *   PagingUtil 은 상한(pageNo > totalPage)만 보정하고 하한도 자릿수도 보지 않는다.
 *   목록 화면은 컨트롤러가 값을 한 번 걸러주지만 AJAX 두 곳
 *   (MyOrderController.searchMyOrderList, PrdController.selectPrdListAjax)은
 *   HashMap 으로 그대로 받아 여기까지 통과한다.
 *
 *   여기 적힌 단언이 Phase 2 에서 고칠 내용의 명세다.
 */
public class PagingUtilTest {

	/** 화면이 넘긴 값을 그대로 흉내낸다. 컨트롤러가 문자열로 받아 넘기기 때문이다. */
	private HashMap<String, Object> params(String pageNo, String pageSize, String totalCnt) {
		HashMap<String, Object> map = new HashMap<String, Object>();
		if (pageNo != null)    map.put("pageNo", pageNo);
		if (pageSize != null)  map.put("pageSize", pageSize);
		if (totalCnt != null)  map.put("totalCnt", totalCnt);
		return map;
	}

	/**
	 * 숫자가 아닌 pageNo 는 기본값으로 떨어져야 한다.
	 *
	 * 지금은 Integer.parseInt 가 NumberFormatException 을 던지고,
	 * 컨트롤러의 catch 가 그것을 삼켜 화면에 "상품이 없습니다" 가 뜬다.
	 * 값이 잘못됐다는 사실이 어디에도 남지 않는다.
	 */
	@Test
	public void pageNo가_숫자가_아니면_1로_보정된다() {
		HashMap<String, Object> map = params("abc", null, "100");

		PagingUtil.setPagingMap(map);   // 지금은 여기서 NumberFormatException 이 난다

		assertThat(map.get("pageNo")).isEqualTo(1);
	}

	/**
	 * 음수 pageNo 는 1로 올라와야 한다.
	 *
	 * 지금은 하한이 없어 limitStart 가 음수가 된다.
	 * 그 값이 SQL 의 LIMIT #{limitStart}, #{pageSize} 로 그대로 들어간다.
	 */
	@Test
	public void 음수_pageNo가_음수_OFFSET을_만들지_않는다() {
		HashMap<String, Object> map = params("-999999", null, "100");

		PagingUtil.setPagingMap(map);

		assertThat((Integer) map.get("pageNo")).isGreaterThanOrEqualTo(1);
		assertThat((Integer) map.get("limitStart")).isGreaterThanOrEqualTo(0);
	}

	/**
	 * pageSize 에는 상한이 있어야 한다.
	 *
	 * 지금은 넘어온 값을 그대로 LIMIT 에 쓴다.
	 * 요청 하나로 테이블 전체를 읽어가게 만들 수 있다.
	 */
	@Test
	public void pageSize에_상한이_있다() {
		HashMap<String, Object> map = params("1", "999999", "100");

		PagingUtil.setPagingMap(map);

		assertThat((Integer) map.get("pageSize")).isBetween(1, 100);
	}
}
