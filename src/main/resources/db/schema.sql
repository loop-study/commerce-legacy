-- ============================================
-- Commerce Legacy E-Commerce DDL (MySQL 5.7)
-- 앱 개발 DB(docker-compose.yml)와 벤치마크(bench/)가 이 파일 하나를 공유한다.
-- ============================================

-- 회원 테이블
CREATE TABLE IF NOT EXISTS TB_MBR (
    MBR_NO          VARCHAR(20)     PRIMARY KEY,
    LOGIN_ID        VARCHAR(50)     NOT NULL UNIQUE,
    PWD             VARCHAR(200)    NOT NULL,
    MBR_NM          VARCHAR(50)     NOT NULL,
    HP_NO           VARCHAR(20),
    EMAIL           VARCHAR(100),
    MBR_STAT_CD     VARCHAR(10)     DEFAULT '10',       -- 10:정상, 20:휴면, 30:탈퇴, 40:블랙리스트
    MBR_GRD_CD      VARCHAR(10)     DEFAULT '10',       -- 10:일반 (현재 등급별 차등 없음. 기획전/복지몰처럼 등급별 가격·노출 제어가 필요해지면 등급 추가)
    ZIPCODE         VARCHAR(10),
    BASE_ADDR       VARCHAR(200),
    DTL_ADDR        VARCHAR(200),
    LOGIN_FAIL_CNT  INT             DEFAULT 0,
    REG_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UPD_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- 카테고리 관리
CREATE TABLE IF NOT EXISTS TB_CAT_MNG (
    CAT_CD          VARCHAR(20)     PRIMARY KEY,
    CAT_NM          VARCHAR(100)    NOT NULL,
    UP_CAT_CD       VARCHAR(20),
    CAT_LVL         INT             DEFAULT 1,          -- 1:대, 2:중, 3:소
    SORT_SEQ        INT             DEFAULT 0,
    USE_YN          VARCHAR(1)      DEFAULT 'Y'
);

-- 상품마스터
CREATE TABLE IF NOT EXISTS TB_PRD_MST (
    PRD_CD          VARCHAR(20)     PRIMARY KEY,
    PRD_NM          VARCHAR(200)    NOT NULL,
    SMPL_DESC       VARCHAR(500),
    PRD_STAT_CD     VARCHAR(10)     DEFAULT '30',       -- 30:판매중, 40:일시품절, 50:예약판매, 90:판매종료
    DELV_TP_CD      VARCHAR(10)     DEFAULT '10',       -- 10:자체배송, 20:택배사
    L_CAT_CD        VARCHAR(20),
    M_CAT_CD        VARCHAR(20),
    S_CAT_CD        VARCHAR(20),
    STOCK_QTY       INT             DEFAULT 0,          -- 0:재고 미관리(수량제한 없이 판매), 1이상:해당 수량만큼만 판매
                                                        -- 주문 시 차감하고, 0 이하가 되면 PRD_STAT_CD를 40(일시품절)로 바꾸려 한다.
                                                        -- 즉 재고 0의 의미는 상태값으로 구분됨 (0+30=미관리, 0+40=소진)
                                                        -- ※ 단 조회→판단→차감이 분리돼 있어 동시 주문에서는 음수로 내려가고
                                                        --   품절 전환도 걸리지 않는다. repro/oversell.sh 참고
                                                        -- ※ 소진(0+40) 상품을 재고 입력 없이 판매중으로 되돌리면 미관리로 바뀌는 함정 있음
    REG_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UPD_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- 상품가격
CREATE TABLE IF NOT EXISTS TB_PRD_PRC (
    PRD_CD          VARCHAR(20)     PRIMARY KEY,
    SALE_PRC        DECIMAL(12,0)   DEFAULT 0,
    CARD_DISC_PRC   DECIMAL(12,0)   DEFAULT 0,
    CASH_DISC_PRC   DECIMAL(12,0)   DEFAULT 0,
    CPN_NO          VARCHAR(20),
    REG_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- 상품이미지
CREATE TABLE IF NOT EXISTS TB_PRD_IMG (
    IMG_NO          INT             AUTO_INCREMENT PRIMARY KEY,
    PRD_CD          VARCHAR(20)     NOT NULL,
    IMG_PATH        VARCHAR(500),
    IMG_NAME        VARCHAR(200),                       -- 저장 파일명 (PRD_CD + 순번 + 확장자)
    IMG_TP_CD       VARCHAR(10)     DEFAULT '10',       -- 10:대표이미지, 20:상세이미지
    SORT_SEQ        INT             DEFAULT 0,
    -- 목록 조회가 상품마다 이 테이블을 통째로 훑던 것을 잡으려고 추가.
    -- PK 가 IMG_NO(일련번호)라 정작 조인에 쓰는 PRD_CD 에는 인덱스가 없었다.
    KEY IX_PRD_IMG_01 (PRD_CD, IMG_TP_CD, SORT_SEQ)
);

-- 장바구니
CREATE TABLE IF NOT EXISTS TB_CART (
    CART_NO         INT             AUTO_INCREMENT PRIMARY KEY,
    MBR_NO          VARCHAR(20)     NOT NULL,
    PRD_CD          VARCHAR(20)     NOT NULL,
    ORD_QTY         INT             DEFAULT 1,
    REG_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    UPD_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    KEY IX_CART_01 (MBR_NO)
);

-- 주문마스터
CREATE TABLE IF NOT EXISTS TB_ORD_MST (
    ORD_NO          VARCHAR(20)     PRIMARY KEY,
    MBR_NO          VARCHAR(20)     NOT NULL,
    ORD_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    ORD_STAT_CD     VARCHAR(10)     DEFAULT '10',       -- 10:주문확인, 20:결제완료, 30:배송준비, 40:배송중, 50:배송완료, 90:주문취소
    PAY_TP_CD       VARCHAR(10)     DEFAULT '10',       -- 10:무통장입금(현금결제), 20:카드결제
    PAY_AMT         DECIMAL(12,0)   DEFAULT 0,
    DEPOSITOR_NM    VARCHAR(50),                        -- 무통장입금 입금자명 (관리자 입금 대조용)
    PG_APRV_NO      VARCHAR(30),                        -- 카드결제 PG 승인번호
    DELV_AMT        DECIMAL(12,0)   DEFAULT 0,
    RECIVER_NM      VARCHAR(50),
    DELV_HP_NO      VARCHAR(20),
    DELV_ZIPCODE    VARCHAR(10),
    DELV_BASE_ADDR  VARCHAR(200),
    DELV_DTL_ADDR   VARCHAR(200),
    DELV_MSG        VARCHAR(500),
    KEY IX_ORD_MST_01 (MBR_NO, ORD_DT),                 -- 마이페이지 주문내역 (회원 + 기간)
    KEY IX_ORD_MST_02 (ORD_DT)                          -- 관리자 주문관리 기간검색
);

-- 주문상세
CREATE TABLE IF NOT EXISTS TB_ORD_DTL (
    ORD_NO          VARCHAR(20)     NOT NULL,
    ORD_SEQ         INT             NOT NULL,
    PRD_CD          VARCHAR(20)     NOT NULL,
    ORD_QTY         INT             DEFAULT 1,
    ORD_AMT         DECIMAL(12,0)   DEFAULT 0,
    SALE_PRC        DECIMAL(12,0)   DEFAULT 0,
    DISC_AMT        DECIMAL(12,0)   DEFAULT 0,
    DELV_STAT_CD    VARCHAR(10)     DEFAULT '10',       -- 10:주문확인, 30:배송준비, 40:배송중, 50:배송완료
    PRIMARY KEY (ORD_NO, ORD_SEQ)
);

-- 임시 주문
-- 주문서로 진입하는 시점에 주문번호를 만들어 여기 담아둔다.
-- 결제가 끝나면 해당 주문번호의 행을 지운다.
CREATE TABLE IF NOT EXISTS TB_ORD_TEMP (
    ORD_NO          VARCHAR(20)     PRIMARY KEY,
    MBR_NO          VARCHAR(20)     NOT NULL,
    ORD_PRD_JSON    TEXT            NOT NULL,           -- 선택 상품/수량 [{"prdCd":"...","ordQty":1}]
    FROM_CART       VARCHAR(1)      DEFAULT 'N',
    CART_NO_LIST    VARCHAR(500),
    REG_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    KEY IX_ORD_TEMP_01 (MBR_NO)
);

-- 관리자
CREATE TABLE IF NOT EXISTS TB_ADMIN (
    ADMIN_NO    VARCHAR(20)     PRIMARY KEY,
    LOGIN_ID    VARCHAR(50)     NOT NULL UNIQUE,
    PWD         VARCHAR(200)    NOT NULL,
    ADMIN_NM    VARCHAR(50)     NOT NULL,
    HP_NO       VARCHAR(20),
    EMAIL       VARCHAR(100),
    REG_DT      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- 배송정보
CREATE TABLE IF NOT EXISTS TB_ORD_DELV_INFO (
    ORD_DELV_NO     INT             AUTO_INCREMENT PRIMARY KEY,
    ORD_NO          VARCHAR(20)     NOT NULL,
    DELV_CO_CD      VARCHAR(10),
    INVOICE_NO      VARCHAR(50),
    DELV_STAT_CD    VARCHAR(10)     DEFAULT '10',
    REG_DT          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);
