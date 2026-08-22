package com.commerce.support;

import javax.annotation.Resource;
import javax.sql.DataSource;

import org.junit.runner.RunWith;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * 서비스 계층 통합 테스트의 바탕
 *
 * 웹 없이 서비스와 매퍼만 띄운다. 그게 가능한 것은 루트 컨텍스트가
 * 이미 웹과 분리돼 있기 때문이다 — context-common.xml 이 @Controller 를
 * 스캔에서 빼고 있어서 서비스·매퍼만 올라온다.
 * dispatcher-servlet.xml 은 ServletContext 를 요구하므로 여기 넣지 않는다.
 *
 * 운영 설정은 한 줄도 고치지 않았다. 바뀌는 것은 클래스패스 앞에 놓인
 * 테스트 사본 두 개뿐이다 (config/jdbc.properties, messages/message-common.properties).
 *
 * ※ @Transactional 을 붙이지 않는다.
 *   - 테스트가 트랜잭션을 열면 서비스의 *Tx 가 그 트랜잭션에 합류(REQUIRED)해
 *     서비스 자신의 커밋·롤백을 관찰할 수 없게 된다.
 *   - 동시성 테스트는 스레드가 달라 애초에 트랜잭션을 공유하지 못한다.
 *   대신 각 테스트가 자기가 쓸 데이터를 직접 세운다.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {
		"classpath:test-context-datasource.xml",
		"classpath:com/spring/context-common.xml",
		"classpath:com/spring/context-mapper.xml",
		"classpath:com/spring/context-transaction.xml"
})
public abstract class AbstractServiceIT {

	@Resource
	private DataSource dataSource;

	private JdbcTemplate jdbcTemplate;

	/** 단언과 사전 준비에 쓴다. 검증은 매퍼를 거치지 않고 DB 를 직접 본다. */
	protected JdbcTemplate jdbc() {
		if (jdbcTemplate == null) {
			jdbcTemplate = new JdbcTemplate(dataSource);
		}
		return jdbcTemplate;
	}
}
