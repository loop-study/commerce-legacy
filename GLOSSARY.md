# 용어사전

SI/SM 현장에서는 테이블명·컬럼명·변수명을 마음대로 짓지 않는다.
용어사전에 등록된 축약어를 조합해서 만든다. `상품코드` 는 `상품(PRD)` + `코드(CD)` 로 `PRD_CD` 가 된다.

이 문서는 이 저장소에 실제로 쓰인 축약어를 모은 것이다.
컬럼 91개에서 축약 토큰 61개가 나왔다.

> 사전이 없으면 `SMPL_DESC` 가 무슨 뜻인지 알 방법이 없다.
> 규칙을 못 지킨 이름은 아래 [사전과 어긋난 것](#사전과-어긋난-것) 에 모아뒀다.

---

## 업무 영역

| 축약 | 원어 | 뜻 | 예 |
|---|---|---|---|
| MBR | Member | 회원 | `MBR_NO` `MBR_GRD_CD` |
| PRD | Product | 상품 | `PRD_CD` `PRD_NM` |
| CAT | Category | 카테고리 | `CAT_CD` `CAT_LVL` |
| ORD | Order | 주문 | `ORD_NO` `ORD_DT` |
| CART | Cart | 장바구니 | `CART_NO` |
| DELV | Delivery | 배송 | `DELV_HP_NO` `DELV_CO_CD` |
| PAY | Payment | 결제 | `PAY_AMT` `PAY_TP_CD` |
| ADMIN | Administrator | 관리자 | `ADMIN_NO` |
| IMG | Image | 이미지 | `IMG_PATH` |
| CPN | Coupon | 쿠폰 | `CPN_NO` |
| PG | Payment Gateway | 결제대행 | `PG_APRV_NO` |

## 자료형·속성

| 축약 | 원어 | 뜻 | 예 |
|---|---|---|---|
| CD | Code | 코드 | `PRD_STAT_CD` |
| NO | Number | 번호 | `ORD_NO` |
| NM | Name | 명칭 | `PRD_NM` |
| DT | Date/Time | 일시 | `REG_DT` |
| QTY | Quantity | 수량 | `ORD_QTY` |
| AMT | Amount | 금액 | `PAY_AMT` |
| PRC | Price | 가격 | `SALE_PRC` |
| CNT | Count | 건수 | `LOGIN_FAIL_CNT` |
| SEQ | Sequence | 순번 | `SORT_SEQ` |
| YN | Yes/No | 여부 | `USE_YN` |
| TP | Type | 유형 | `IMG_TP_CD` |
| STAT | Status | 상태 | `MBR_STAT_CD` |
| LVL | Level | 단계 | `CAT_LVL` |
| GRD | Grade | 등급 | `MBR_GRD_CD` |

## 행위·시점

| 축약 | 원어 | 뜻 | 예 |
|---|---|---|---|
| REG | Register | 등록 | `REG_DT` |
| UPD | Update | 수정 | `UPD_DT` |
| SALE | Sale | 판매 | `SALE_PRC` |
| DISC | Discount | 할인 | `DISC_AMT` |
| APRV | Approval | 승인 | `PG_APRV_NO` |
| SORT | Sort | 정렬 | `SORT_SEQ` |
| LOGIN | Login | 로그인 | `LOGIN_ID` |
| FAIL | Fail | 실패 | `LOGIN_FAIL_CNT` |

## 주소·연락처

| 축약 | 원어 | 뜻 | 예 |
|---|---|---|---|
| ADDR | Address | 주소 | `DELV_BASE_ADDR` |
| BASE | Base | 기본 | `DELV_BASE_ADDR` |
| DTL | Detail | 상세 | `DELV_DTL_ADDR` |
| HP | Hand Phone | 휴대전화 | `HP_NO` |
| MSG | Message | 메시지 | `DELV_MSG` |

## 수식어

| 축약 | 원어 | 뜻 | 예 |
|---|---|---|---|
| L / M / S | Large / Medium / Small | 대 / 중 / 소 | `L_CAT_CD` |
| UP | Upper | 상위 | `UP_CAT_CD` |
| SMPL | Simple | 간단 | `SMPL_DESC` |
| CO | Company | 회사 | `DELV_CO_CD` |
| MST | Master | 마스터 | `TB_ORD_MST` |

## 테이블 접두

| 축약 | 뜻 |
|---|---|
| TB_ | Table. 모든 테이블에 붙인다 |
| IX_ | Index. `IX_{테이블}_{순번}` |

---

## 조합 규칙

```
{업무영역}_{수식어}_{속성}

PRD_STAT_CD    상품(PRD) + 상태(STAT) + 코드(CD)
DELV_BASE_ADDR 배송(DELV) + 기본(BASE) + 주소(ADDR)
L_CAT_CD       대(L) + 카테고리(CAT) + 코드(CD)
```

테이블은 `TB_{업무영역}_{구분}` 이다. `TB_ORD_MST`(주문 마스터), `TB_ORD_DTL`(주문 상세).

---

## 사전과 어긋난 것

규칙대로면 다르게 지어야 하는데 그렇게 안 된 이름들이다.
사전을 안 열어보고 지었거나, 줄이는 걸 깜빡했거나, `NM` 과 `NAME` 을 헷갈린 것이다.
쫓기면서 만들다 보면 이렇게 샌다.

| 컬럼 | 어긋난 점 |
|---|---|
| `RECIVER_NM` | `RECEIVER` 철자 오류 |
| `IMG_NAME` | 이름은 `NM` 인데 여기만 `NAME` 으로 썼다 |
| `ZIPCODE` | 축약도, 업무영역 접두도 없다 |
| `DEPOSITOR_NM` | 안 줄였다 |
| `INVOICE_NO` | 안 줄였다 |
| `STOCK_QTY` | 안 줄였다 |
| `IMG_PATH` | 안 줄였다 |
| `SMPL_DESC` | `DESC` 가 SQL 예약어와 철자가 같다 |

**고치지 않는다.** 이미 만들어서 쓰고 있기 때문이다.
컬럼명 하나를 바꾸려면 스키마·SQL·VO·JSP 를 동시에 손대야 하고,
그러다 어디 하나 빠뜨리면 런타임에서야 터진다. 그 비용을 감수할 이유가 없으니 그대로 간다.

`RECIVER_NM` 은 [TECH_DEBT.md](TECH_DEBT.md) 에도 부채로 올려두었다.

---

## 이 사전 자체가 부채다

용어사전은 코드 바깥에 있다. 엑셀이나 위키에 있고, 컬럼을 만들 때 사람이 열어보고 맞춘다.

- 강제하는 장치가 없다. 안 보고 지어도 아무도 모른다
- 사전과 코드가 갈라져도 알려주지 않는다. 위 표가 그 결과다
- 사전을 잃어버리면 `SMPL_DESC` 를 해독할 방법이 사라진다

컴파일러도 테스트도 이걸 잡지 못한다. 사람이 규칙을 지키는 동안만 성립하는 규칙이다.
그래서 어긋난 것이 쌓여도 아무 일도 일어나지 않고, 쌓인 뒤에는 고칠 수 없게 된다.
