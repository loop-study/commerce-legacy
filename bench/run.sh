#!/bin/bash
# ============================================================
#  commerce-legacy 성능 측정 러너
#
#  현재 레거시 코드가 얼마나 느리고 왜 느린지를 숫자와 실행계획으로 확인한다.
#  스키마는 앱과 동일하게 PK 만 있고 인덱스가 없다. 그 상태를 그대로 잰다.
#
#  규모를 바꿔가며 잰다
#    1천 / 3천 / 5천 / 1만  — 부채가 어느 지점부터 드러나는가
#    당시 세대 엔진에서는 1만 건부터 이미 응답이 없다.
#
#  사용법
#    ./run.sh init [규모] [버전]    기동 + 스키마 + 데이터 적재
#                                   기본값 3000, 5.7
#    ./run.sh info                  버전 / 건수 / 분포 / OFFSET 확인
#    ./run.sh bench [라벨]          6개 쿼리 측정
#    ./run.sh explain q1            실행계획 (왜 느린가)
#    ./run.sh coldrun q1            재시작 후 콜드/웜 비교
#    ./run.sh sweep [버전]          1천·3천·5천·1만 연속 측정
#    ./run.sh down                  컨테이너 폐기
# ============================================================
set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
SQLDIR="$DIR/sql"
CT="commerce-bench-mysql"
DB="commerce_bench"
PW="bench"

# ★ 스키마는 앱과 공유한다.
#   사본을 따로 두면 앱 스키마를 고치고 이쪽을 안 고쳤을 때
#   "앱을 측정하지 않는 벤치"가 되어버린다. 그래서 원본을 직접 읽는다.
APP_SCHEMA="$DIR/../src/main/resources/db/schema.sql"

PAGE_SIZE=12      # 앱의 상품목록 1페이지 건수와 동일
RUNS=5            # 쿼리당 반복 측정 횟수 (중앙값을 취한다)
QUERIES="q1 q2 q3 q4 q5 q6"

# 측정 전 버리는 실행 횟수.
#
# ★ 이게 없으면 결과가 왜곡된다. 실제로 겪은 함정이라 기록해둔다.
#   버퍼풀이 차가운 상태에서 시작하면 먼저 도는 쪽이 워밍 비용을
#   혼자 떠안아, 조건이 같은데도 다른 숫자가 나온다.
#   앞의 몇 회를 버려서 같은 출발선에 세운다.
WARMUP=3

# 쿼리 1회 제한시간(ms).
# 인덱스가 없으면 조인 비용이 O(상품수 × 이미지수) 로 폭발해서
# 한 번 실행에 몇 시간이 걸린다. 끝까지 기다리는 건 의미가 없고,
# "제한시간 내 응답 없음" 자체가 결과다. 그렇게 기록한다.
TIMEOUT_MS=20000

OFFSET_FILE="$DIR/.offset"
STATE_FILE="$DIR/.state"      # 현재 적재된 규모/버전 기록

# ── mysql 실행 헬퍼 ────────────────────────────────────────
# MYSQL_PWD 로 비밀번호를 넘겨 "insecure" 경고를 없앤다.
# --comments: mysql 클라이언트는 기본적으로 주석을 떼고 서버에 보낸다.
#            그러면 SHOW PROFILES 결과에서 어느 행이 어느 쿼리인지
#            구분할 표식(/* BENCH:qN */)이 사라진다. 반드시 켜야 한다.
msql() {
    docker exec -i -e MYSQL_PWD="$PW" "$CT" \
        mysql -uroot --comments --default-character-set=utf8mb4 -N -B "$@" "$DB"
}
msql_table() {
    docker exec -i -e MYSQL_PWD="$PW" "$CT" \
        mysql -uroot --comments --default-character-set=utf8mb4 "$@" "$DB"
}

engine_version() {
    echo "SELECT VERSION();" | msql 2>/dev/null | head -1
}
is_mysql8() {
    case "$(engine_version)" in 8.*) return 0 ;; *) return 1 ;; esac
}

wait_ready() {
    printf "MySQL 기동 대기"
    local i
    for i in $(seq 1 90); do
        if echo "SELECT 1;" | msql >/dev/null 2>&1; then
            echo " → 준비 완료"; return 0
        fi
        printf "."; sleep 2
    done
    echo " → 실패"; return 1
}

# ── 쿼리 파일의 플레이스홀더를 채운다 ──────────────────────
render() {
    local off=0
    [ -f "$OFFSET_FILE" ] && off=$(cat "$OFFSET_FILE")
    sed -e "s/{{PAGE_SIZE}}/$PAGE_SIZE/g" -e "s/{{OFFSET}}/$off/g" "$1"
}

# ── 한 쿼리를 실행하고 중앙값(ms)을 낸다 ───────────────────
#   측정은 DB 안에서 한다. 셸에서 time 으로 재면 접속·연결 비용이
#   섞여 들어가는데, 그게 쿼리 자체보다 클 수도 있기 때문이다.
#
#   같은 쿼리도 잴 때마다 시간이 다르다(백그라운드 작업, OS 스케줄링).
#   1회만 재면 잡음에 휘둘리고, 평균은 한 번 크게 튄 값이 전체를 끌어올린다.
#   중앙값은 튄 값에 흔들리지 않으므로 중앙값을 쓴다.
run_sql_profiled() {   # $1=쿼리파일  $2=반복횟수
    local i
    {
        echo "SET SESSION profiling = 1;"
        echo "SET SESSION profiling_history_size = 100;"
        echo "SET SESSION max_execution_time = $TIMEOUT_MS;"
        for i in $(seq 1 "$2"); do render "$1"; done
        echo "SELECT '###PROFILES###';"
        echo "SHOW PROFILES;"
    } | msql 2>&1
}

median_ms() {   # stdin: run_sql_profiled 출력  $1=취할 뒤쪽 개수
    awk '/###PROFILES###/{f=1; next} f && /BENCH:/ {print $2}' \
      | tail -n "${1:-99999}" \
      | sort -g \
      | awk '{a[NR]=$1}
             END {
               if (NR == 0) { print "NA"; exit }
               m = int((NR + 1) / 2);
               if (NR % 2) printf "%.1f\n", a[m] * 1000;
               else        printf "%.1f\n", (a[m] + a[m+1]) / 2 * 1000;
             }'
}

measure() {
    local qf="$SQLDIR/$1.sql" out
    out=$(run_sql_profiled "$qf" 1)
    if echo "$out" | grep -q "execution time exceeded"; then
        echo "timeout"; return
    fi
    run_sql_profiled "$qf" $((WARMUP + RUNS)) | median_ms "$RUNS"
}

label_of() {
    case "$1" in
        q1) echo "목록 1페이지(최신순)" ;;
        q2) echo "목록 마지막페이지" ;;
        q3) echo "카테고리 필터(대중소)" ;;
        q4) echo "키워드 검색(LIKE)" ;;
        q5) echo "목록 총건수(COUNT)" ;;
        q6) echo "가격순 정렬" ;;
        *)  echo "$1" ;;
    esac
}

# 한글은 터미널에서 2칸을 차지하는데 printf 는 바이트로 세기 때문에
# 라벨을 가운데 두면 표가 어긋난다. 숫자를 먼저 찍고 라벨을 뒤로 보낸다.
cmd_bench() {
    local tag="${1:-$(cat "$STATE_FILE" 2>/dev/null || echo 현재상태)}"
    echo ""
    echo "=== 측정 : $tag ==================================="
    echo "  엔진 MySQL $(engine_version)"
    echo "  워밍업 ${WARMUP}회 버린 뒤 ${RUNS}회 중앙값 (ms). buffer pool warm."
    echo "  timeout = ${TIMEOUT_MS}ms 내 응답 없음"
    echo ""
    printf "%-4s %12s   %s\n" "쿼리" "시간(ms)" "설명"
    printf "%-4s %12s   %s\n" "----" "------------" "--------------------"
    local q
    for q in $QUERIES; do
        printf "%-4s %12s   %s\n" "$q" "$(measure "$q")" "$(label_of "$q")"
    done
    echo ""
}

# ── 콜드 측정 ───────────────────────────────────────────────
# 같은 쿼리도 처음 실행할 때(버퍼풀이 비어 디스크에서 읽어야 함)와
# 두 번째(이미 램에 있음)가 다르다. 실제 장애는 콜드 쪽에 가깝다.
# 매 반복마다 재시작해야 진짜 콜드라 비용이 커서, 본 측정은 웜으로 하고
# 콜드는 이 명령으로 따로 본다.
#
# ※ 한계 : 컨테이너를 껐다 켜도 호스트의 파일 캐시는 남는다.
#          실제 서버의 콜드보다 낙관적인 수치다.
cmd_coldrun() {
    local q="${1:-q1}" cold warm
    docker restart "$CT" >/dev/null
    wait_ready >/dev/null || exit 1
    cold=$(run_sql_profiled "$SQLDIR/$q.sql" 1 | median_ms)
    warm=$(run_sql_profiled "$SQLDIR/$q.sql" $((WARMUP + RUNS)) | median_ms "$RUNS")
    printf "%-4s  cold %10s ms   warm %10s ms   %s\n" \
           "$q" "$cold" "$warm" "$(label_of "$q")"
}

# EXPLAIN = DB 가 "나는 이렇게 처리하겠다"고 내놓는 계획서.
# 측정 시간이 "얼마나 느린가"라면 EXPLAIN 은 "왜 느린가"를 알려준다.
#   type/access_type: ALL  -> 풀스캔
#   Using filesort         -> 정렬을 따로 하고 있다
#   Block Nested Loop      -> 조인 상대를 반복해서 훑고 있다 (당시 세대의 기본)
#   rows                   -> 훑을 예정인 행 수
#
# 8.0 은 FORMAT=TREE 가 읽기 쉽고, 5.7 은 그게 없어서 FORMAT=JSON 을 쓴다.
# JSON 에도 조인 중첩 구조가 그대로 들어 있다.
cmd_explain() {
    local q="${1:-q1}"
    echo ""
    echo "=== EXPLAIN : $q  (MySQL $(engine_version)) ==================="
    { echo "EXPLAIN"; render "$SQLDIR/$q.sql"; } | msql_table --table 2>/dev/null

    echo ""
    if is_mysql8; then
        echo "--- 실행계획 트리 ---"
        # 배치 출력은 줄바꿈을 \n 으로 escape 하므로 되돌려 읽기 좋게 만든다
        { echo "EXPLAIN FORMAT=TREE"; render "$SQLDIR/$q.sql"; } \
          | msql 2>/dev/null | sed 's/\\n/\
/g'
    else
        echo "--- 실행계획 구조 (FORMAT=JSON 요약) ---"
        { echo "EXPLAIN FORMAT=JSON"; render "$SQLDIR/$q.sql"; } | msql 2>/dev/null \
        | python3 -c '
import sys, json
raw = sys.stdin.read().replace("\\n", "\n")
try: d = json.loads(raw)
except Exception: print(raw[:800]); sys.exit()
KEYS = ("table_name","access_type","rows_examined_per_scan","using_join_buffer",
        "using_filesort","attached_condition")
def walk(o, dep=0):
    if isinstance(o, dict):
        if "table" in o and isinstance(o["table"], dict):
            t = o["table"]
            line = "  "*dep + "- " + str(t.get("table_name"))
            line += "  " + str(t.get("access_type"))
            if t.get("rows_examined_per_scan") is not None:
                line += "  rows=" + str(t["rows_examined_per_scan"])
            if t.get("using_join_buffer"):
                line += "  [" + t["using_join_buffer"] + "]"
            print(line)
        for k, v in o.items():
            if k in ("using_filesort",) and v:
                print("  "*dep + "* Using filesort")
            if isinstance(v, (dict, list)):
                walk(v, dep + (1 if k in ("nested_loop","ordering_operation") else 0))
    elif isinstance(o, list):
        for i in o: walk(i, dep)
walk(d)
'
    fi
    echo ""
}

calc_offset() {
    local off
    off=$(echo "SELECT FLOOR((COUNT(*)-1)/$PAGE_SIZE)*$PAGE_SIZE
                FROM TB_PRD_MST WHERE PRD_STAT_CD IN ('30','40','50');" | msql)
    echo "$off" > "$OFFSET_FILE"
    echo "$off"
}

cmd_up() {
    ( cd "$DIR" && BENCH_MYSQL_VERSION="${1:-5.7}" docker compose up -d )
    wait_ready || exit 1
}

cmd_init() {
    local rows="${1:-100000}" ver="${2:-5.7}"
    # 버전을 바꾸려면 컨테이너를 새로 만들어야 한다
    ( cd "$DIR" && docker compose down >/dev/null 2>&1 )
    cmd_up "$ver"
    # 앱 스키마에는 DROP 이 없고 CREATE TABLE IF NOT EXISTS 라서,
    # 깨끗한 상태를 보장하려면 DB 를 통째로 새로 만든다.
    echo "DB 재생성..."
    docker exec -i -e MYSQL_PWD="$PW" "$CT" mysql -uroot \
        -e "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB DEFAULT CHARSET utf8mb4;" 2>/dev/null
    echo "스키마 생성 (앱과 동일: src/main/resources/db/schema.sql)..."
    msql < "$APP_SCHEMA"
    echo "데이터 적재 (상품 $(printf "%'d" "$rows") / 이미지 그 3배)... 규모에 따라 수십 초~수 분"
    sed "s/{{ROWS}}/$rows/g" "$SQLDIR/02-data.sql" | msql >/dev/null
    echo "MySQL $(engine_version) / 상품 $(printf "%'d" "$rows")" > "$STATE_FILE"
    echo "완료"
    cmd_info
}

cmd_info() {
    echo ""
    echo "=== 환경 ==========================================="
    echo "SELECT CONCAT('  MySQL 버전      : ', VERSION());" | msql
    echo "SELECT CONCAT('  버퍼풀 크기     : ', ROUND(@@innodb_buffer_pool_size/1024/1024), ' MB');" | msql
    echo ""
    echo "=== 데이터 ========================================="
    {
    echo "SELECT CONCAT('  TB_PRD_MST      : ', FORMAT(COUNT(*),0), ' 건') FROM TB_PRD_MST;"
    echo "SELECT CONCAT('  TB_PRD_IMG      : ', FORMAT(COUNT(*),0), ' 건') FROM TB_PRD_IMG;"
    echo "SELECT CONCAT('  조회대상(30/40/50): ', FORMAT(COUNT(*),0), ' 건') FROM TB_PRD_MST WHERE PRD_STAT_CD IN ('30','40','50');"
    echo "SELECT CONCAT('  LIKE 프라이팬     : ', FORMAT(COUNT(*),0), ' 건') FROM TB_PRD_MST WHERE PRD_STAT_CD IN ('30','40','50') AND (PRD_NM LIKE '%프라이팬%' OR SMPL_DESC LIKE '%프라이팬%');"
    echo "SELECT CONCAT('  데이터 크기       : ', ROUND(SUM(DATA_LENGTH+INDEX_LENGTH)/1024/1024), ' MB') FROM information_schema.TABLES WHERE TABLE_SCHEMA='$DB';"
    } | msql
    echo ""
    echo "  q2 의 마지막페이지 OFFSET : $(calc_offset)"
    echo ""
}

# 규모를 바꿔가며 연속 측정한다.
# 부채는 데이터가 적을 땐 보이지 않는다. 한 지점만 재면 그 성질을 못 보여준다.
cmd_sweep() {
    local ver="${1:-5.7}" rows
    for rows in 1000 3000 5000 10000; do
        cmd_init "$rows" "$ver"
        cmd_bench "MySQL $ver / 상품 $(printf "%'d" "$rows")"
    done
    echo "스윕 완료. 결과를 RESULT.md 에 옮겨 적으세요."
}

case "${1:-help}" in
    init)    cmd_init "${2:-3000}" "${3:-5.7}" ;;
    info)    cmd_info ;;
    bench)   cmd_bench "${2:-}" ;;
    explain) cmd_explain "${2:-q1}" ;;
    coldrun) cmd_coldrun "${2:-q1}" ;;
    sweep)   cmd_sweep "${2:-5.7}" ;;
    down)    ( cd "$DIR" && docker compose down -v ) ;;
    *)       sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
