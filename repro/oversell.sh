#!/bin/bash
# ============================================================
#  재고 경쟁 재현 — 재고보다 많이 팔린다
#
#  재고 처리가 **조회 → 판단 → 차감** 세 단계로 나뉘어 있다.
#
#      int qty = orderMapper.selectPrdStockQty(map);   // ① 읽고
#      if (qty > 0) {                                  // ② 판단하고
#          orderMapper.updatePrdStockDecrease(map);    // ③ 뺀다
#      }
#
#  그리고 차감 UPDATE 에 **재고 조건이 없다.**
#
#      UPDATE TB_PRD_MST SET STOCK_QTY = STOCK_QTY - ${ordQty}
#      WHERE PRD_CD = #{prdCd}          ← 재고가 얼마든 그냥 뺀다
#
#  ①과 ③ 사이에 다른 요청이 끼어들면 둘 다 "재고 있음"으로 판단하고,
#  차감은 조건 없이 실행되므로 **재고가 음수로 내려간다.**
#
#  사용법
#    docker compose up -d && mvn tomcat7:run-war
#    ./repro/oversell.sh [재고] [동시요청수]
# ============================================================
set -u

BASE="${BASE:-http://localhost:8080}"
STOCK="${1:-5}"
N="${2:-20}"
PRD="${PRD:-P000000001}"

DB() { docker exec -i -e MYSQL_PWD=commerce commerce-db \
        mysql -uroot --default-character-set=utf8mb4 -N -B commerce 2>/dev/null; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
die() { echo "  ✗ $*"; exit 1; }

curl -s -o /dev/null -m 5 "$BASE/main.do" || die "앱이 응답하지 않는다 ($BASE)"
docker ps --filter name=commerce-db --format '{{.Names}}' | grep -q commerce-db \
  || die "DB 컨테이너가 없다"

# ── 준비 ────────────────────────────────────────────────────
echo "UPDATE TB_PRD_MST SET STOCK_QTY=$STOCK, PRD_STAT_CD='30' WHERE PRD_CD='$PRD';" | DB
before_ord=$(echo "SELECT COUNT(*) FROM TB_ORD_MST;" | DB)

echo "== 준비 =="
echo "  상품 $PRD  재고 $STOCK 개로 설정"
echo "  동시에 $N 명이 1개씩 주문한다  → 정상이라면 $STOCK 건만 성공해야 한다"

curl -s -c "$TMP/u.txt" -X POST "$BASE/selectLoginProc.do" \
     -d "loginId=user01&pwd=password123" | grep -q SUCCESS || die "로그인 실패"

# ── 동시 주문 ───────────────────────────────────────────────
echo
echo "== 동시 주문 $N 건 =="
for i in $(seq 1 "$N"); do
  curl -s -b "$TMP/u.txt" -X POST "$BASE/od/order/saveOrder.do" \
    -d "prdCd=$PRD&ordQty=1&payTpCd=10&depositorNm=경쟁" \
    -d "reciverNm=경쟁&delvHpNo=010-0000-0000&delvZipcode=06134" \
    -d "delvBaseAddr=서울시&delvDtlAddr=1층&delvMsg=" \
    -o "$TMP/res_$i.json" &
done
wait

ok=$(grep -l '"rtnCode":"SUCCESS"' "$TMP"/res_*.json 2>/dev/null | wc -l | tr -d ' ')
sold=$(grep -l 'SOLD_OUT' "$TMP"/res_*.json 2>/dev/null | wc -l | tr -d ' ')
after_stock=$(echo "SELECT STOCK_QTY FROM TB_PRD_MST WHERE PRD_CD='$PRD';" | DB)
after_stat=$(echo "SELECT PRD_STAT_CD FROM TB_PRD_MST WHERE PRD_CD='$PRD';" | DB)
after_ord=$(echo "SELECT COUNT(*) FROM TB_ORD_MST;" | DB)
made=$((after_ord - before_ord))

# ── 대조 ────────────────────────────────────────────────────
echo
echo "== 대조 =="
cut=$((STOCK - after_stock))
printf "  팔려야 할 수량 : %s 개\n" "$STOCK"
printf "  실제 주문 성공 : %s 건   (재고부족 거부 %s 건)\n" "$ok" "$sold"
printf "  주문 생성      : %s 건\n" "$made"
printf "  실제 차감      : %s 회   ← 성공 건수와 다르다\n" "$cut"
printf "  남은 재고      : %s\n" "$after_stock"
printf "  상품 상태      : %s  (30=판매중 / 40=일시품절)\n" "$after_stat"

echo
echo "== 읽는 법 =="
if [ "$after_stock" -lt 0 ] 2>/dev/null; then
  over=$((ok - STOCK))
  skip=$((ok - cut))
  echo "  재현됨 — $STOCK 개짜리를 $ok 건 팔았고 재고는 $after_stock 이다."
  echo "  $over 건은 없는 재고를 판 것이다."
  echo
  echo "  [1단계] 조회와 차감이 분리돼 있고 차감 UPDATE 에 재고 조건이 없다."
  echo "          동시 요청이 서로를 지나쳐 재고가 0 아래로 내려간다."
  echo
  echo "  [2단계] 재고가 0 이하가 되면 차감이 **멈춘다.**"
  echo "          이 코드에서 0 은 '재고 미관리(무제한)' 를 뜻하기 때문이다."
  echo
  echo "              if (salePssbQty > 0) {          // 0 이하면 건너뛴다"
  echo "                  updatePrdStockDecrease(..);"
  echo "              }"
  echo
  printf "          성공 %s 건 중 실제로 차감된 것은 %s 회뿐이다.\n" "$ok" "$cut"
  printf "          나머지 %s 건은 재고를 건드리지도 못했다.\n" "$skip"
  echo
  echo "  → 재고가 음수가 되는 데서 끝나지 않는다. 그 순간부터"
  echo "    **재고 관리가 통째로 무력화되고 무제한 판매가 된다.**"
  if [ "$after_stat" = "30" ]; then
    echo "    품절 전환도 안 걸린다 — 각 요청이 자기가 읽은 값으로 판단하기 때문이다."
  fi
else
  echo "  이번엔 재고가 남았다($after_stock). 타이밍이 어긋나면 재현되지 않는다."
  echo "  동시요청수를 늘려 다시 돌려보면 된다 :  ./repro/oversell.sh $STOCK 50"
fi

echo
echo "== 뒷정리 =="
echo "UPDATE TB_PRD_MST SET STOCK_QTY=500, PRD_STAT_CD='30' WHERE PRD_CD='$PRD';" | DB
echo "  재고를 500 으로 되돌렸다 (생성된 주문 $made 건은 남겨둔다)"
