package com.commerce.support;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;

import javax.annotation.Resource;

import org.junit.Test;

import com.commerce.ec.od.order.service.OrderService;

/**
 * 컨텍스트가 웹 없이 뜨는지만 본다.
 *
 * 이 하나가 통과하면 나머지 통합 테스트를 얹을 바닥이 생긴 것이다.
 * 실패한다면 원인은 셋 중 하나다 — DB 컨테이너가 없거나(docker compose up -d),
 * 스키마 적재가 깨졌거나, 스캔 대상에 웹 의존이 섞였거나.
 */
public class ContextLoadsIT extends AbstractServiceIT {

	@Resource(name = "orderService")
	private OrderService orderService;

	@Test
	public void 서비스_빈이_웹_없이_올라온다() {
		assertThat(orderService).isNotNull();
	}

	@Test
	public void 스키마와_시드_데이터가_적재된다() {
		Integer prdCnt = jdbc().queryForObject("SELECT COUNT(*) FROM TB_PRD_MST", Integer.class);
		Integer mbrCnt = jdbc().queryForObject("SELECT COUNT(*) FROM TB_MBR", Integer.class);

		assertThat(prdCnt).isGreaterThan(0);
		assertThat(mbrCnt).isGreaterThan(0);
	}

	@Test
	public void 매퍼가_실제_DB를_친다() throws Exception {
		HashMap<String, Object> param = new HashMap<String, Object>();
		param.put("mbrNo", "M000000001");

		HashMap<String, Object> mbrInfo = orderService.selectMbrInfo(param);

		assertThat(mbrInfo).isNotNull();
		assertThat(mbrInfo.get("mbrNo")).isEqualTo("M000000001");
	}
}
