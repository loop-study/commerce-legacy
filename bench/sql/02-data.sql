-- ============================================================
-- 벤치마크용 데이터 생성
--
-- {{ROWS}} 는 run.sh 가 채운다 (10000 / 100000 / 500000 ...).
--
-- ★ 숫자 생성에 재귀 CTE 를 쓰지 않는다.
--   CTE 는 MySQL 8.0 에서 처음 들어온 문법이라 5.7 에서는 아예 안 돈다.
--   당시 세대(5.x)와 지금 세대(8.0)를 같은 파일로 재려면
--   양쪽에서 도는 방식이어야 한다. 그래서 숫자 테이블 cross join 을 쓴다.
--   0~9 짜리 테이블 여섯 개를 곱하면 100만까지 만들 수 있다.
--
-- 데이터 분포는 우연이 아니라 설계다. 이유는 각 주석 참고.
-- ============================================================

-- ------------------------------------------------------------
-- 0) 숫자 테이블 (0~9)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS BENCH_NUMS;
CREATE TABLE BENCH_NUMS (N INT PRIMARY KEY) ENGINE=InnoDB;
INSERT INTO BENCH_NUMS (N) VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- ------------------------------------------------------------
-- 1) 카테고리 (앱의 data.sql 과 동일한 14건)
-- ------------------------------------------------------------
INSERT INTO TB_CAT_MNG (CAT_CD, CAT_NM, UP_CAT_CD, CAT_LVL, SORT_SEQ, USE_YN) VALUES
 ('L001', '생활용품',  NULL,   1, 1, 'Y'),
 ('L002', '식품',      NULL,   1, 2, 'Y'),
 ('L003', '뷰티',      NULL,   1, 3, 'Y'),
 ('M001', '주방용품',  'L001', 2, 1, 'Y'),
 ('M002', '욕실용품',  'L001', 2, 2, 'Y'),
 ('M003', '간식/음료', 'L002', 2, 1, 'Y'),
 ('M004', '건강식품',  'L002', 2, 2, 'Y'),
 ('M005', '스킨케어',  'L003', 2, 1, 'Y'),
 ('S001', '프라이팬',  'M001', 3, 1, 'Y'),
 ('S002', '냄비',      'M001', 3, 2, 'Y'),
 ('S003', '수건',      'M002', 3, 1, 'Y'),
 ('S004', '과자',      'M003', 3, 1, 'Y'),
 ('S005', '건강즙',    'M004', 3, 1, 'Y'),
 ('S006', '로션',      'M005', 3, 1, 'Y');

-- ------------------------------------------------------------
-- 2) 상품마스터 {{ROWS}} 건
--
-- 설계 의도 3가지
--
--  (가) 상품명에 진짜 검색 키워드를 심는다
--       n % 6 으로 6종을 돌려 프라이팬/냄비/수건/과자/건강즙/로션이
--       각 약 1/6 씩 생긴다.
--       상품명이 전부 "벤치상품 1,2,3..." 이면 LIKE '%프라이팬%' 이
--       0건을 반환하고, 0건 쿼리는 결과 처리 비용이 없어서 실제보다
--       빠르게 나온다. 그러면 측정이 헛돈다.
--
--  (나) 상태 분포를 한쪽으로 몰아둔다
--       판매중 85% / 품절 5% / 예약 5% / 종료 5%.
--       앱의 조회 조건 IN ('30','40','50') 에 95%가 걸린다.
--       -> 조건문이 사실상 아무것도 걸러내지 못한다는 것을 보여주는 장치.
--
--  (다) 카테고리는 키워드와 일관되게 붙인다
--       L001 50% / L002 33% / L003 17%, 소분류는 각 약 17%.
-- ------------------------------------------------------------
INSERT INTO TB_PRD_MST
  (PRD_CD, PRD_NM, SMPL_DESC, PRD_STAT_CD, DELV_TP_CD,
   L_CAT_CD, M_CAT_CD, S_CAT_CD, STOCK_QTY, REG_DT, UPD_DT)
SELECT
    CONCAT('P', LPAD(n, 9, '0')),
    CASE n % 6
        WHEN 0 THEN CONCAT('프리미엄 코팅 프라이팬 ', 20 + (n % 5) * 2, 'cm')
        WHEN 1 THEN CONCAT('스테인리스 냄비 ',       16 + (n % 4) * 2, 'cm')
        WHEN 2 THEN CONCAT('호텔식 순면 수건 ',       3 + (n % 8),      '매')
        WHEN 3 THEN CONCAT('프리미엄 과자 선물세트 ', 100 + (n % 10) * 50, 'g')
        WHEN 4 THEN CONCAT('유기농 건강즙 ',          30 + (n % 4) * 30, '포')
        ELSE        CONCAT('수분 보습 로션 ',        100 + (n % 5) * 50, 'ml')
    END,
    -- LIKE 가 PRD_NM 과 SMPL_DESC 를 모두 훑으므로 여기에도 한글을 넣는다
    CASE n % 6
        WHEN 0 THEN '논스틱 코팅, 인덕션 겸용, 가정용 주방 필수품'
        WHEN 1 THEN '18/10 스테인리스, 통3중 바닥, 열전도 균일'
        WHEN 2 THEN '40수 순면 100%, 호텔급 두께, 흡수력 우수'
        WHEN 3 THEN '개별포장, 명절 선물용, 유통기한 12개월'
        WHEN 4 THEN '국내산 원물, 무첨가, 휴대용 파우치 포장'
        ELSE        '히알루론산 함유, 민감성 피부용, 무향 무색소'
    END,
    CASE
        WHEN n % 20 = 7  THEN '40'
        WHEN n % 20 = 13 THEN '50'
        WHEN n % 20 = 19 THEN '90'
        ELSE '30'
    END,
    CASE WHEN n % 3 = 0 THEN '20' ELSE '10' END,
    CASE WHEN n % 6 IN (0,1,2) THEN 'L001'
         WHEN n % 6 IN (3,4)   THEN 'L002'
         ELSE 'L003' END,
    CASE n % 6
        WHEN 0 THEN 'M001' WHEN 1 THEN 'M001' WHEN 2 THEN 'M002'
        WHEN 3 THEN 'M003' WHEN 4 THEN 'M004' ELSE 'M005' END,
    CASE n % 6
        WHEN 0 THEN 'S001' WHEN 1 THEN 'S002' WHEN 2 THEN 'S003'
        WHEN 3 THEN 'S004' WHEN 4 THEN 'S005' ELSE 'S006' END,
    CASE WHEN n % 7 = 0 THEN 0 ELSE (n % 900) + 100 END,
    -- 등록일을 1분 간격으로 과거로 흩뿌린다.
    -- ORDER BY REG_DT DESC 정렬 실험을 위해 값이 고르게 분산되어야 한다
    DATE_SUB(NOW(), INTERVAL n MINUTE),
    DATE_SUB(NOW(), INTERVAL n MINUTE)
FROM (
    SELECT a.N + b.N*10 + c.N*100 + d.N*1000 + e.N*10000 + f.N*100000 + 1 AS n
    FROM BENCH_NUMS a, BENCH_NUMS b, BENCH_NUMS c,
         BENCH_NUMS d, BENCH_NUMS e, BENCH_NUMS f
) seq
WHERE n <= {{ROWS}};

-- ------------------------------------------------------------
-- 3) 상품가격 (1:1)
--    상품코드의 숫자부분으로 5,000 ~ 104,800원을 결정론적으로 만든다.
--    카드/현금 할인가는 앱에서 필수값이므로 둘 다 채운다.
-- ------------------------------------------------------------
INSERT INTO TB_PRD_PRC (PRD_CD, SALE_PRC, CARD_DISC_PRC, CASH_DISC_PRC, REG_DT)
SELECT
    PRD_CD,
    base,
    FLOOR(base * 0.95 / 10) * 10,
    FLOOR(base * 0.90 / 10) * 10,
    REG_DT
FROM (
    SELECT PRD_CD, REG_DT,
           5000 + (CAST(SUBSTRING(PRD_CD, 2) AS UNSIGNED) % 500) * 200 AS base
    FROM TB_PRD_MST
) t;

-- ------------------------------------------------------------
-- 4) 상품이미지 (상품당 대표 1 + 상세 2 = 3배)
--
--    이 테이블이 이번 측정의 주인공이다.
--    PRD_CD 에 인덱스가 없는데 목록 조회마다 조인한다.
--    상품보다 3배 크므로 조인 비용이 여기서 터진다.
-- ------------------------------------------------------------
INSERT INTO TB_PRD_IMG (PRD_CD, IMG_PATH, IMG_NAME, IMG_TP_CD, SORT_SEQ)
SELECT PRD_CD, CONCAT('/images/prd/', L_CAT_CD, '/', PRD_CD, '_1.jpg'),
       CONCAT(PRD_CD, '_1.jpg'), '10', 1 FROM TB_PRD_MST;

INSERT INTO TB_PRD_IMG (PRD_CD, IMG_PATH, IMG_NAME, IMG_TP_CD, SORT_SEQ)
SELECT PRD_CD, CONCAT('/images/prd/', L_CAT_CD, '/', PRD_CD, '_d1.jpg'),
       CONCAT(PRD_CD, '_d1.jpg'), '20', 1 FROM TB_PRD_MST;

INSERT INTO TB_PRD_IMG (PRD_CD, IMG_PATH, IMG_NAME, IMG_TP_CD, SORT_SEQ)
SELECT PRD_CD, CONCAT('/images/prd/', L_CAT_CD, '/', PRD_CD, '_d2.jpg'),
       CONCAT(PRD_CD, '_d2.jpg'), '20', 2 FROM TB_PRD_MST;

DROP TABLE BENCH_NUMS;

-- 옵티마이저가 최신 행수/분포를 보고 판단하도록 통계를 갱신한다.
-- 빼먹으면 "인덱스를 안 탄다"의 원인이 선택도 때문인지
-- 통계가 낡아서인지 구분할 수 없다.
ANALYZE TABLE TB_PRD_MST, TB_PRD_PRC, TB_PRD_IMG, TB_CAT_MNG;
