# 프로젝트 구조

> 이 저장소가 어떤 환경이고 어떻게 짜여 있는지 찾아보는 문서.
> 컬럼 / 변수명의 축약 규칙은 [GLOSSARY.md](GLOSSARY.md).
> 부채 목록은 [TECH_DEBT.md](TECH_DEBT.md), 실행 방법은 [README.md](README.md),
> 부채 재현은 [repro/](repro/), 성능 측정은 [bench/](bench/).

## 기술 스택
- Spring 4.3.30, Java 1.8, MyBatis 3.4.6, MySQL 5.7(Docker), Tiles 3.0.8, JSP
  - 당시 세대에 맞춰 5.7 유지. 최신 버전으로 올리는 것은 그 자체로 개선이다
- Bootstrap 4.6.2, jQuery 3.7.1
- 빌드: Maven, tomcat7-maven-plugin (port 8080). JDK 8 필수
- DB: 별도 컨테이너 (`docker compose up -d` → localhost:3307/commerce, root/commerce)
  - 접속정보 `src/main/resources/config/jdbc.properties`
  - 스키마 & 데이터는 컨테이너 최초 생성 시 1회만 적재된다. 이후 데이터는 유지됨
  - 초기화: `docker compose down && docker volume rm commerce-legacy_commerce-db-data && docker compose up -d`
    (`down -v` 는 Docker 20.10.x 실험적 compose 에서 볼륨을 안 지움)
- 벤치마크용 MySQL 도 5.7, 별도 컨테이너(3308) — `bench/` 참고. 앱 스키마를 그대로 적재한다

## 코딩 패턴
- Controller → Service(인터페이스) → ServiceImpl → Mapper(인터페이스) → MyBatis XML
- `@Resource(name="서비스명")` 주입, `@Service("서비스명")` 명명
- `HashMap<String, Object>` 파라미터/리턴, `rtnCode`/`rtnMsg` AJAX 응답
- 트랜잭션 메서드: `*Tx` 접미사 (AOP 기반, context-transaction.xml)
- Tiles 뷰: `.main`(FO), `.join`(회원가입), `.admin`(BO)
- 공통 정적 리소스: `src/main/webapp/common/{css,js}` — 레이아웃 `<head>` 에서 로드
- PagingUtil: `PagingUtil.setPagingMap(HashMap)` static 메서드

## 패키지 구조
```
com.commerce.ec      ← FO
├── cm/login/          ← 로그인 (LoginController, LoginService)
├── cmmn/              ← 공통 (PagingVO, LoginHandlerInterceptor, AdminLoginHandlerInterceptor)
│   └── utils/         ← SessionUtil, PagingUtil, MapUtil, NumberUtil
├── dp/main/           ← FO 메인 페이지
├── dp/prd/            ← FO 상품 목록/상세 (URL은 /dp/good)
├── mb/join/           ← 회원가입
├── od/cart/           ← 장바구니
├── od/order/          ← 주문
└── my/order/          ← 마이페이지 주문내역

com.commerce.admin   ← BO
├── cm/login/          ← 관리자 로그인
├── od/order/          ← 주문 관리
└── prd/               ← 상품 관리 (URL은 /admin/gd, JSP는 admin/gd/)
```

## DB 스키마 (src/main/resources/db/schema.sql)
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| TB_MBR | 회원 | MBR_NO(PK), LOGIN_ID, PWD, MBR_NM, MBR_STAT_CD[10정상/20휴면/30탈퇴/40블랙], MBR_GRD_CD[10일반] |
| TB_CAT_MNG | 카테고리 3레벨 | CAT_CD(PK), CAT_NM, UP_CAT_CD, CAT_LVL[1대/2중/3소] |
| TB_PRD_MST | 상품마스터 | PRD_CD(PK), PRD_NM, PRD_STAT_CD[30판매중/40품절/50예약/90종료], L_CAT_CD/M_CAT_CD/S_CAT_CD(필수), STOCK_QTY[0=미관리/N=한정], DELV_TP_CD[10자체/20업체] |
| TB_PRD_PRC | 상품가격 | PRD_CD(PK), SALE_PRC, CARD_DISC_PRC, CASH_DISC_PRC |
| TB_PRD_IMG | 상품이미지 | IMG_NO(PK auto), PRD_CD, IMG_PATH, IMG_TP_CD[10대표/20상세], SORT_SEQ |
| TB_CART | 장바구니 | CART_NO(PK auto), MBR_NO, PRD_CD, ORD_QTY |
| TB_ORD_MST | 주문마스터 | ORD_NO(PK), MBR_NO, ORD_STAT_CD[10확인/20결제/30준비/40배송중/50완료/90취소], PAY_TP_CD[10무통장/20카드], PAY_AMT, DEPOSITOR_NM(입금자명), RECIVER_NM, DELV_* |
| TB_ORD_DTL | 주문상세 | ORD_NO+ORD_SEQ(PK), PRD_CD, ORD_QTY, ORD_AMT, SALE_PRC, DISC_AMT |
| TB_ORD_DELV_INFO | 배송정보 | ORD_DELV_NO(PK auto), ORD_NO, DELV_CO_CD, INVOICE_NO |
| TB_ORD_TEMP | 임시주문 (결제 준비 단계) | ORD_NO(PK), MBR_NO, ORD_PRD_JSON(선택 상품/수량), FROM_CART, CART_NO_LIST |
| TB_ADMIN | 관리자 | ADMIN_NO(PK), LOGIN_ID(UNIQUE), PWD, ADMIN_NM, HP_NO, EMAIL |

## 테스트 데이터 (src/main/resources/db/data.sql)
- 회원 3명: user01, user02, user03(휴면), 비번 모두 password123 (등급은 모두 일반)
- 상품 80개: P000000001~P000000080 (P7=품절, P10=판매종료, 나머지는 페이징 확인용)
- 카테고리: L001생활용품, L002식품, L003뷰티 + 중/소 카테고리
- 주문 25건, 장바구니 2건(user01)

## MyBatis 설정 (sql-mapper-config.xml)
- mapUnderscoreToCamelCase: true
- typeAlias: hashMap, pagingVO, cartVO, ordVO, joinUserVO, memberVO, prdDtlVO, prdRegVO
- MapperScanner: `com.commerce.ec..service.impl`, `com.commerce.admin..service.impl`

## Spring 설정
- dispatcher-servlet.xml: Controller 스캔, Tiles(order=1) + JSP(order=2) ViewResolver
- LoginHandlerInterceptor: `/od/`, `/my/` — 회원 로그인 체크 (`memberVO`)
- AdminLoginHandlerInterceptor: `/admin/**` — 관리자 로그인 체크 (`adminVO`, login.do 제외)
- context-transaction.xml: save*, insert*, delete*, update*, *Tx → REQUIRED, rollback

## Tiles 레이아웃 (WEB-INF/tiles/default-layout.xml)
- `*/*/*.main` → FO (main-layouts.jsp: header + content + footer)
- `*/*/*.join` → 회원가입 (같은 레이아웃)
- `*/*.admin` → BO (admin-layouts.jsp: admin-header + content + footer)
- `*/*.adminLogin` → 관리자 로그인 (레이아웃 없음)

---

## 모듈별 구현 상세

### 회원 - 로그인 (cm/login)
- LoginController: /login.do (로그인폼), /selectLoginProc.do (로그인처리 AJAX), /selectLogout.do (로그아웃)
- 세션: MemberVO 저장 (`sessionScope.memberVO`)

### 회원 - 회원가입 (mb/join)
- JoinController: /mb/join/joinAgree.do (약관동의), /mb/join/joinInput.do (정보입력), /mb/join/dupIdCheck.do (아이디중복확인 AJAX), /mb/join/saveJoinMbr.do (저장 AJAX), /mb/join/joinComplete.do (완료)
- 3단계 흐름: 약관동의(필수 2건) → 정보입력 → 가입완료. 약관 미동의 시 joinInput에서 joinAgree로 반려
- 회원번호 채번: M + 9자리 (selectMaxMbrNo + 1), 비밀번호 SHA-256

### FO 메인 (/main.do)
- MainController: 대카테고리 목록 + 최신 판매중 상품 8건
- MainSQL: selectCategoryList, selectNewPrdList

### FO 상품 목록 (/dp/good/prdList.do)
- PrdController.prdList: lCatCd, mCatCd, searchKeyword, pageNo 파라미터
- 카테고리 필터 + 키워드 검색 + 페이징(12건/페이지)
- AJAX: /dp/good/selectPrdListAjax.do

### FO 상품 상세 (/dp/good/prdDtl.do)
- PrdController.prdDtl: prdCd 파라미터
- prdDtl.jsp: 브레드크럼 + 이미지 + 가격표 + 장바구니/바로구매 버튼

### BO 주문 관리 (/admin/od/ordList.do)
- OrdMngController: 목록(기간/상태/결제수단/회원 검색) + 상세 모달(AJAX)
- 주문상태 변경: 다음 단계 1단계씩만 진행(10→20→30→40→50) + 취소(90). 취소 시 재고 복원
- 배송정보 등록: 배송준비(30) 이후만 가능, 등록 시 30이면 배송중(40)으로 자동 전환
- 택배사 코드: CJ / HANJIN / LOTTE / POST / LOGEN

### BO 상품 관리 (/admin/gd/prdMng.do)
- PrdMngController: 목록/등록폼/저장/삭제(상태변경→90)
- 상품코드 자동생성(P + 9자리), 카테고리 AJAX 연동

### 장바구니 (od/cart)
- CartController + CartService + CartServiceImpl + CartMapper
- CartSQL.xml, cartList.jsp
- URL: /od/cart/cartInit.do (목록), /od/cart/addCart.do (추가), /od/cart/updateCart.do (수량변경), /od/cart/deleteCart.do (삭제)
- 중복 상품 추가 시 수량 합산 처리

### 주문 (od/order)
- OrderController + OrderService + OrderServiceImpl + OrderMapper
- OrderSQL.xml, orderForm.jsp, orderSuccess.jsp
- URL: /od/order/orderInit.do (주문서), /od/order/prepareOrder.do (결제준비), /od/order/saveOrder.do (AJAX저장), /od/order/orderSuccess.do (완료)
- 주문번호는 결제하기를 누를 때 만든다. 카드결제만 prepareOrder 로 채번 + TB_ORD_TEMP 저장을 거치고,
  무통장입금은 saveOrder 안에서 채번해 바로 확정한다
- 카드결제는 PG 승인 후 저장이 실패하면 승인을 취소한다 (PgApiUtil.cancel → /mock/pg/cancel.do)
- 장바구니 주문(fromCart=Y) + 바로구매(prdCd+ordQty) 양쪽 지원
- 주문번호: ORD + yyyyMMdd + 4자리 랜덤
- 재고 처리: `STOCK_QTY 0`=미관리(무제한), `1이상`=한정판매. 주문 시 체크 후 차감,
  0 이하가 되면 `PRD_STAT_CD`를 40(일시품절)로 전환 (0의 의미를 상태값으로 구분)
  - 조회 → 판단 → 차감이 분리돼 있고 차감 `UPDATE`에 재고 조건이 없다.
    동시 주문이면 재고가 음수로 내려가고 품절 전환도 걸리지 않는다 (`repro/oversell.sh`)
- 재고 부족 시 `rtnCode=SOLD_OUT` 반환, 주문 취소 시 재고 복원 + 품절→판매중 복귀
- 무통장입금(10) 선택 시 입금자명(`DEPOSITOR_NM`) 필수. 주문완료 화면에 입금 안내 노출
  (무통장 + 주문확인(10) 상태에서만, 입금기한 = 주문일 +3일)
- 계좌정보: `src/main/resources/messages/message-common.properties` → `CmmnMessage`로 조회
- 결제 중에는 공통 로딩 레이어가 화면을 덮는다 (`comm_loading.loadingShow/Hide`).
  중복 결제를 막는 것이 사실상 이 레이어다. 서버에는 같은 주문을 두 번 받는 것을 막는 장치가 없다

### 마이페이지 (my/order)
- MyOrderController + MyOrderService + MyOrderServiceImpl + MyOrderMapper
- MyOrderSQL.xml, myOrderList.jsp
- URL: /my/order/myOrderList.do (목록 + 기간검색 1/3/6개월/전체)
- 페이징(10건/페이지), 카드 형태 UI

---

## URL 맵

@RequestMapping 에서 뽑은 전체 목록이다. 42개.

| URL | 컨트롤러 | 설명 |
|-----|----------|------|
| /main.do | MainController | 메인 |
| /login.do | LoginController | 로그인 폼 |
| /selectLoginProc.do | LoginController | 로그인 처리(AJAX) |
| /selectLogout.do | LoginController | 로그아웃 |
| /mb/join/joinAgree.do | JoinController | 약관동의 |
| /mb/join/joinInput.do | JoinController | 정보입력 |
| /mb/join/dupIdCheck.do | JoinController | 아이디 중복확인(AJAX) |
| /mb/join/saveJoinMbr.do | JoinController | 회원가입 저장(AJAX) |
| /mb/join/joinComplete.do | JoinController | 가입완료 |
| /dp/good/prdList.do | PrdController | 상품목록 |
| /dp/good/prdDtl.do | PrdController | 상품상세 |
| /dp/good/selectPrdListAjax.do | PrdController | 상품목록 조회(AJAX) |
| /od/cart/cartInit.do | CartController | 장바구니 |
| /od/cart/addCart.do | CartController | 장바구니 담기(AJAX) |
| /od/cart/updateCart.do | CartController | 수량 변경(AJAX) |
| /od/cart/deleteCart.do | CartController | 삭제(AJAX) |
| /od/order/orderInit.do | OrderController | 주문서 |
| /od/order/prepareOrder.do | OrderController | 결제 준비 - 채번 + 임시주문 저장(카드결제) |
| /od/order/saveOrder.do | OrderController | 주문 저장(AJAX) |
| /od/order/orderSuccess.do | OrderController | 주문완료 |
| /my/order/myOrderList.do | MyOrderController | 주문내역 |
| /my/order/searchMyOrderList.do | MyOrderController | 주문내역 기간검색(AJAX) |
| /my/order/myOrderDtl.do | MyOrderController | 주문상세 |
| /my/order/cancelMyOrder.do | MyOrderController | 주문취소(AJAX) |
| /admin/login.do | AdminLoginController | 관리자 로그인 폼 |
| /admin/selectLoginProc.do | AdminLoginController | 관리자 로그인 처리(AJAX) |
| /admin/selectLogout.do | AdminLoginController | 관리자 로그아웃 |
| /admin/gd/prdMng.do | PrdMngController | 상품관리 목록 |
| /admin/gd/prdReg.do | PrdMngController | 상품 등록폼 |
| /admin/gd/savePrd.do | PrdMngController | 상품 저장(AJAX) |
| /admin/gd/deletePrd.do | PrdMngController | 상품 삭제(AJAX) |
| /admin/gd/selectSubCatList.do | PrdMngController | 하위 카테고리 조회(AJAX) |
| /admin/gd/catMng.do | CatMngController | 카테고리 관리 |
| /admin/gd/saveCat.do | CatMngController | 카테고리 저장(AJAX) |
| /admin/gd/deleteCat.do | CatMngController | 카테고리 삭제(AJAX) |
| /admin/gd/selectCatDtl.do | CatMngController | 카테고리 상세(AJAX) |
| /admin/od/ordList.do | OrdMngController | 주문관리 목록 |
| /admin/od/selectOrdDtl.do | OrdMngController | 주문 상세(AJAX) |
| /admin/od/updateOrdStat.do | OrdMngController | 주문상태 변경(AJAX) |
| /admin/od/saveOrdDelvInfo.do | OrdMngController | 배송정보 등록(AJAX) |
| /mock/pg/approve.do | MockPgController | 모의 PG 승인 |
| /mock/pg/cancel.do | MockPgController | 모의 PG 승인취소 |
