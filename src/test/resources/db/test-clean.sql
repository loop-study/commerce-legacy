-- ============================================================
--  테스트 시작 전 테이블 정리
--
--  schema.sql 은 CREATE TABLE IF NOT EXISTS 라 다시 돌려도 되지만
--  data.sql 은 INSERT 뿐이라 두 번째 실행에서 PK 중복으로 깨진다.
--  이전 실행이 남긴 주문 데이터도 함께 지워야 하므로
--  테이블을 통째로 지우고 다시 만든다.
--
--  대상은 commerce_test 다. 앱이 쓰는 commerce 스키마가 아니다.
-- ============================================================
DROP TABLE IF EXISTS TB_ORD_DELV_INFO;
DROP TABLE IF EXISTS TB_ORD_TEMP;
DROP TABLE IF EXISTS TB_ORD_DTL;
DROP TABLE IF EXISTS TB_ORD_MST;
DROP TABLE IF EXISTS TB_CART;
DROP TABLE IF EXISTS TB_PRD_IMG;
DROP TABLE IF EXISTS TB_PRD_PRC;
DROP TABLE IF EXISTS TB_PRD_MST;
DROP TABLE IF EXISTS TB_CAT_MNG;
DROP TABLE IF EXISTS TB_MBR;
DROP TABLE IF EXISTS TB_ADMIN;
