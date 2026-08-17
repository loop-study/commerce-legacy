#!/bin/bash
# ============================================================
#  동시성 미처리 재현 — MAX + 1 채번이 같은 번호를 내준다
#
#  회원번호를 이렇게 만든다.
#
#      String maxMbrNo = joinMapper.selectMaxMbrNo();   // ① 읽고
#      int seq = parseInt(maxMbrNo.substring(1)) + 1;   // ② 더하고
#      joinMapper.insertJoinMbr(vo);                    // ③ 넣는다
#
#  ①과 ③ 사이에 다른 요청이 끼어들면 **둘이 같은 번호를 받는다.**
#  MBR_NO 는 PK 라 뒤늦은 쪽의 INSERT 가 깨지고,
#  그 요청은 그대로 실패한다 — 재시도도 대체 채번도 없다.
#
#  상품코드(selectMaxPrdCd)·카테고리코드(selectMaxCatCd)도 같은 구조다.
#
#  사용법
#    docker compose up -d && mvn tomcat7:run-war
#    ./repro/concurrent-signup.sh [동시요청수]
# ============================================================
set -u

BASE="${BASE:-http://localhost:8080}"
N="${1:-20}"

DB() { docker exec -i -e MYSQL_PWD=commerce commerce-db \
        mysql -uroot --default-character-set=utf8mb4 -N -B commerce 2>/dev/null; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
die() { echo "  ✗ $*"; exit 1; }

curl -s -o /dev/null -m 5 "$BASE/main.do" || die "앱이 응답하지 않는다 ($BASE)"
docker ps --filter name=commerce-db --format '{{.Names}}' | grep -q commerce-db \
  || die "DB 컨테이너가 없다"

TAG="rp$$"                       # 이번 실행분만 골라내기 위한 표식
before=$(echo "SELECT COUNT(*) FROM TB_MBR;" | DB)

echo "== 준비 =="
echo "  기존 회원 $before 명 / 동시 가입 시도 $N 건"
echo "  아이디는 ${TAG}_1 ~ ${TAG}_$N (전부 서로 다르다)"

# ── 동시 가입 ───────────────────────────────────────────────
# 아이디가 전부 다르므로, 실패한다면 원인은 중복 아이디가 아니라
# **회원번호 채번 충돌**이다.
echo
echo "== 동시 요청 =="
for i in $(seq 1 "$N"); do
  curl -s -X POST "$BASE/mb/join/saveJoinMbr.do" \
    -d "loginId=${TAG}_$i&pwd=password123&pwdConfirm=password123" \
    -d "mbrNm=재현$i&hpNo=010-0000-0000&email=${TAG}_$i@test.co.kr" \
    -d "zipcode=06134&baseAddr=서울시&dtlAddr=1층" \
    -d "agreeYn=Y&privacyYn=Y" \
    -o "$TMP/res_$i.json" &
done
wait

ok=$(grep -l '"rtnCode":"SUCCESS"' "$TMP"/res_*.json 2>/dev/null | wc -l | tr -d ' ')
fail=$((N - ok))
after=$(echo "SELECT COUNT(*) FROM TB_MBR;" | DB)
made=$((after - before))

echo "  성공 응답 : $ok / $N"

# ── 대조 ────────────────────────────────────────────────────
echo
echo "== 대조 =="
printf "  가입 시도 : %s 건\n" "$N"
printf "  실제 생성 : %s 명\n" "$made"
printf "  실패      : %s 건\n" "$fail"

echo
echo "== 읽는 법 =="
if [ "$fail" -gt 0 ]; then
  echo "  ✔ 재현됨 — 아이디는 전부 달랐는데 $fail 건이 실패했다."
  echo "    같은 순간에 MAX 를 읽은 요청들이 **같은 회원번호**를 만들었고,"
  echo "    PK 충돌로 INSERT 가 깨졌다."
  echo
  echo "    실패 응답 :"
  grep -h -o '"rtnMsg":"[^"]*"' "$TMP"/res_*.json 2>/dev/null | sort | uniq -c | sed 's/^/      /'
else
  echo "  이번엔 전부 성공했다. 타이밍이 어긋나면 충돌하지 않는다."
  echo "  동시요청수를 늘려 다시 돌려보면 된다 :  ./repro/concurrent-signup.sh 50"
fi

echo
echo "== 뒷정리 =="
echo "DELETE FROM TB_MBR WHERE LOGIN_ID LIKE '${TAG}\\_%';" | DB
echo "  이번 실행에서 만든 계정을 지웠다 (기존 회원 $before 명 유지)"
