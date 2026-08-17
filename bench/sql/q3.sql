/* BENCH:q3 카테고리 필터 (대>중>소 전부 지정)
   보려는 것 : 조건 인덱스가 실제로 얼마나 효과가 있는가.
   이 데이터에서 S001 은 약 16,600건(전체의 17%)이다.
   17% 는 옵티마이저가 "인덱스로 찾아서 원본을 다시 읽느니
   그냥 전부 훑는 게 싸다"고 판단할 수 있는 애매한 구간이다.
   인덱스를 만들어도 안 탈 수 있고, 그것 자체가 관찰 결과다. */
SELECT
    A.PRD_CD, A.PRD_NM, A.SMPL_DESC, A.PRD_STAT_CD,
    B.SALE_PRC, B.CARD_DISC_PRC, B.CASH_DISC_PRC,
    C.IMG_PATH, D.CAT_NM
FROM TB_PRD_MST A
LEFT JOIN TB_PRD_PRC B ON A.PRD_CD = B.PRD_CD
LEFT JOIN TB_PRD_IMG C ON A.PRD_CD = C.PRD_CD AND C.IMG_TP_CD = '10' AND C.SORT_SEQ = 1
LEFT JOIN TB_CAT_MNG D ON A.L_CAT_CD = D.CAT_CD
WHERE A.PRD_STAT_CD IN ('30', '40', '50')
  AND A.L_CAT_CD = 'L001'
  AND A.M_CAT_CD = 'M001'
  AND A.S_CAT_CD = 'S001'
ORDER BY A.REG_DT DESC
LIMIT {{PAGE_SIZE}} OFFSET 0;
