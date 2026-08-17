/* BENCH:q2 목록 마지막 페이지 (최신순)
   보려는 것 : OFFSET 이 커지면 왜 느려지는가.
   DB 는 OFFSET N 을 "N개를 건너뛴다"가 아니라 "N+LIMIT 개를 만들어놓고
   앞의 N개를 버린다"로 처리한다. 마지막 페이지는 사실상 전체를 정렬하는 셈이다.
   {{OFFSET}} 은 run.sh 가 실제 조회 건수에서 계산해 채운다. */
SELECT
    A.PRD_CD, A.PRD_NM, A.SMPL_DESC, A.PRD_STAT_CD,
    B.SALE_PRC, B.CARD_DISC_PRC, B.CASH_DISC_PRC,
    C.IMG_PATH, D.CAT_NM
FROM TB_PRD_MST A
LEFT JOIN TB_PRD_PRC B ON A.PRD_CD = B.PRD_CD
LEFT JOIN TB_PRD_IMG C ON A.PRD_CD = C.PRD_CD AND C.IMG_TP_CD = '10' AND C.SORT_SEQ = 1
LEFT JOIN TB_CAT_MNG D ON A.L_CAT_CD = D.CAT_CD
WHERE A.PRD_STAT_CD IN ('30', '40', '50')
ORDER BY A.REG_DT DESC
LIMIT {{PAGE_SIZE}} OFFSET {{OFFSET}};
