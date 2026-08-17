#!/bin/bash
# ============================================================
#  외부 API 강결합 재현 — PG 지연이 상관없는 화면까지 멈춘다
#
#  결제 PG 를 주문 트랜잭션 안에서 동기 호출하고, 타임아웃도 없다.
#  PG 가 느려지면 주문 스레드가 커넥션을 쥔 채 대기하고,
#  커넥션 풀(8개)이 마르면 **결제와 아무 상관 없는 상품 조회까지 멈춘다.**
#
#  이 스크립트가 하는 일
#    1. 지연 없는 상태에서 상품 목록 응답시간을 잰다 (기준선)
#    2. PG 지연을 켜고 카드결제를 동시에 여러 건 넣는다
#    3. 그 사이에 상품 목록을 다시 잰다  ← 여기서 느려지면 재현 성공
#    4. 설정을 되돌리고 다시 잰다
#
#  사용법
#    docker compose up -d && mvn tomcat7:run-war   # 앱이 떠 있어야 한다
#    ./repro/pg-delay.sh
# ============================================================
set -u

BASE="${BASE:-http://localhost:8080}"
DELAY_MS="${DELAY_MS:-8000}"     # PG 응답 지연
ORDERS="${ORDERS:-8}"            # 동시에 넣을 주문 수 (커넥션 풀 기본 8개)

DIR="$(cd "$(dirname "$0")/.." && pwd)"
# ★ 경로 주의.
#   tomcat7:run-war 는 target/classes 가 아니라 **전개된 WAR** 를 서비스한다.
#   target/classes 를 고치면 앱은 눈도 깜짝 안 한다. (실제로 한 번 당했다)
PROP="$(find "$DIR/target" -path "*/WEB-INF/classes/messages/message-common.properties" | head -1)"
SRC_PROP="$DIR/src/main/resources/messages/message-common.properties"
COOKIE="$(mktemp)"

cleanup() { rm -f "$COOKIE"; }
trap cleanup EXIT

die() { echo "  ✗ $*"; exit 1; }

# ── 준비 ────────────────────────────────────────────────────
[ -n "$PROP" ] && [ -f "$PROP" ] || die "전개된 WAR 의 properties 를 못 찾았다. mvn package 후 tomcat7:run-war 로 띄웠는지 확인."
curl -s -o /dev/null -m 5 "$BASE/main.do" || die "앱이 응답하지 않는다 ($BASE)"

echo "== 준비 =="
curl -s -c "$COOKIE" -X POST "$BASE/selectLoginProc.do" \
     -d "loginId=user01&pwd=password123" | grep -q SUCCESS \
  || die "로그인 실패"
echo "  로그인 OK (user01)"

# 측정 대상 : 결제와 아무 상관 없는 화면
probe() {
    curl -s -o /dev/null -b "$COOKIE" -w "%{time_total}" "$BASE/dp/good/prdList.do"
}

# messageSource 는 cacheSeconds=60 이라 파일을 고쳐도 최대 60초 뒤에 반영된다.
set_delay() {
    sed -i '' "s/^pg.mock.delay=.*/pg.mock.delay=$1/" "$PROP"
    printf "  설정 반영 대기"
    local i
    for i in $(seq 1 22); do
        sleep 3; printf "."
        # mock PG 를 직접 찔러 실제 반영됐는지 확인한다
        local t
        t=$(curl -s -o /dev/null -w "%{time_total}" -m 30 -X POST "$BASE/mock/pg/approve.do" -d "ordNo=probe&payAmt=1")
        if [ "$1" = "0" ]; then
            awk -v v="$t" 'BEGIN{exit !(v < 1)}' && { echo " → 반영됨 (${t}s)"; return; }
        else
            awk -v v="$t" 'BEGIN{exit !(v > 1)}' && { echo " → 반영됨 (${t}s)"; return; }
        fi
    done
    echo " → 반영 안 됨"; die "properties 반영 실패"
}

# 카드결제 주문을 동시에 넣는다 (바로구매 경로)
fire_orders() {
    local i
    for i in $(seq 1 "$ORDERS"); do
        curl -s -o /dev/null -b "$COOKIE" -X POST "$BASE/od/order/saveOrder.do" \
          -d "prdCd=P000000001&ordQty=1&payTpCd=20" \
          -d "reciverNm=재현&delvHpNo=010-0000-0000&delvZipcode=06134" \
          -d "delvBaseAddr=서울시&delvDtlAddr=1층&delvMsg=" &
    done
}

# ── 1. 기준선 ───────────────────────────────────────────────
echo
echo "== 1. 지연 없음 (기준선) =="
set_delay 0
for i in 1 2 3; do printf "  상품 목록 : %ss\n" "$(probe)"; done

# ── 2. PG 지연 + 동시 주문 ──────────────────────────────────
echo
echo "== 2. PG ${DELAY_MS}ms 지연 + 주문 ${ORDERS}건 동시 =="
set_delay "$DELAY_MS"
fire_orders
sleep 1                       # 주문 스레드가 커넥션을 잡을 시간
echo "  (주문이 PG 응답을 기다리는 동안 연속 측정)"
# 주문이 PG 를 기다리는 창이 곧 닫히므로, 그 안에서 쉬지 않고 잰다.
for i in 1 2 3 4 5; do printf "  상품 목록 : %ss\n" "$(probe)"; done
wait                          # 주문들이 끝날 때까지

# ── 3. 원복 ─────────────────────────────────────────────────
echo
echo "== 3. 지연 해제 후 =="
set_delay 0
for i in 1 2 3; do printf "  상품 목록 : %ss\n" "$(probe)"; done

# 원본 properties 도 0 으로 맞춰둔다
sed -i '' "s/^pg.mock.delay=.*/pg.mock.delay=0/" "$SRC_PROP" 2>/dev/null

echo
echo "== 읽는 법 =="
echo "  2번 구간의 첫 측정이 1·3번보다 크게 느려졌다면 재현 성공이다."
echo "  뒤쪽이 정상으로 돌아오는 건, 주문 ${ORDERS}건이 ${DELAY_MS}ms 만에 끝나"
echo "  커넥션이 곧 반납되기 때문이다. 실제 장애에서는 주문이 계속 들어오므로"
echo "  이 상태가 지속된다. ORDERS 를 늘리면 창이 길어진다."
echo "  결제와 무관한 화면인데도 느려지는 이유는 커넥션 풀이 마르기 때문이다."
echo "  주문 스레드가 PG 응답을 기다리는 내내 커넥션을 쥐고 있고,"
echo "  풀(기본 8개)이 비면 다른 요청은 순서를 기다릴 수밖에 없다."
