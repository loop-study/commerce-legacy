/* BENCH:q5 목록 총건수 (페이징의 전체 페이지 수 계산용)
   보려는 것 : 조인도 정렬도 없이 조건만 있을 때의 순수 비용.
   앱은 목록 화면 한 번에 selectPrdList 와 selectPrdListCnt 를
   둘 다 호출하므로, 이 비용도 사용자 대기시간에 그대로 더해진다.
   COUNT 는 LIMIT 로 잘라낼 수도 없어 조건에 걸리는 전부를 세야 한다. */
SELECT COUNT(*)
FROM TB_PRD_MST A
WHERE A.PRD_STAT_CD IN ('30', '40', '50');
