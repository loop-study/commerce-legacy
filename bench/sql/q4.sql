/* BENCH:q4 키워드 검색 (LIKE '%키워드%')
   보려는 것 : 앞에 와일드카드가 붙은 LIKE 는 B-Tree 인덱스로 풀리지 않는다.
   인덱스는 "앞에서부터 정렬된" 자료구조라 시작점을 모르면 쓸 수 없다.
   전화번호부에서 "김"으로 시작하는 사람은 바로 찾지만
   "이름 중간에 '철'이 들어간 사람"은 처음부터 다 넘겨봐야 하는 것과 같다.
   -> 조건에 맞는 행을 찾으려면 10만 건을 전부 읽어보는 수밖에 없다.

   ※ 주의 : 이 항목은 DB 조회 일반에 대한 교훈이다.
      현업의 검색 도입 배경과는 무관하다(그쪽은 기획단계에서 이미
      외부 검색솔루션으로 결정되어 있었고 DB LIKE 검색이 아니었다). */
SELECT
    A.PRD_CD, A.PRD_NM, A.SMPL_DESC, A.PRD_STAT_CD,
    B.SALE_PRC, B.CARD_DISC_PRC, B.CASH_DISC_PRC,
    C.IMG_PATH, D.CAT_NM
FROM TB_PRD_MST A
LEFT JOIN TB_PRD_PRC B ON A.PRD_CD = B.PRD_CD
LEFT JOIN TB_PRD_IMG C ON A.PRD_CD = C.PRD_CD AND C.IMG_TP_CD = '10' AND C.SORT_SEQ = 1
LEFT JOIN TB_CAT_MNG D ON A.L_CAT_CD = D.CAT_CD
WHERE A.PRD_STAT_CD IN ('30', '40', '50')
  AND (A.PRD_NM LIKE CONCAT('%', '프라이팬', '%')
    OR A.SMPL_DESC LIKE CONCAT('%', '프라이팬', '%'))
ORDER BY A.REG_DT DESC
LIMIT {{PAGE_SIZE}} OFFSET 0;
