/* BENCH:q6 가격순 정렬 (현금할인가 오름차순)
   보려는 것 : 조인해서 붙인 "다른 테이블"의 컬럼으로 정렬할 때.
   정렬 기준(B.CASH_DISC_PRC)이 주 테이블 A 가 아니라 B 에 있어서,
   DB 는 조건에 걸리는 9만여 건을 전부 조인해 붙인 다음에야 정렬할 수 있다.
   LIMIT 12 를 걸어도 12건만 읽고 끝낼 방법이 없다.
   -> 인덱스로는 해결되지 않는 유형. 구조를 바꿔야 하는 문제다. */
SELECT
    A.PRD_CD, A.PRD_NM, A.SMPL_DESC, A.PRD_STAT_CD,
    B.SALE_PRC, B.CARD_DISC_PRC, B.CASH_DISC_PRC,
    C.IMG_PATH, D.CAT_NM
FROM TB_PRD_MST A
LEFT JOIN TB_PRD_PRC B ON A.PRD_CD = B.PRD_CD
LEFT JOIN TB_PRD_IMG C ON A.PRD_CD = C.PRD_CD AND C.IMG_TP_CD = '10' AND C.SORT_SEQ = 1
LEFT JOIN TB_CAT_MNG D ON A.L_CAT_CD = D.CAT_CD
WHERE A.PRD_STAT_CD IN ('30', '40', '50')
ORDER BY B.CASH_DISC_PRC ASC, A.REG_DT DESC
LIMIT {{PAGE_SIZE}} OFFSET 0;
