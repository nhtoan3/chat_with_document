#!/usr/bin/env bash
# OPS-001 — kiểm tra lại bước 4 sau khi web chạy xong `npm ci` (workaround lỗi script test case: script gợi ý không chờ web).
set -uo pipefail
source frontend/e2e/lib.sh
echo "### Bước 4b: Kiểm tra lại endpoint sau khi web sẵn sàng"
"${COMPOSE[@]}" ps -a --format 'table {{.Service}}\t{{.State}}\t{{.Health}}\t{{.Status}}'
"${COMPOSE[@]}" logs --timestamps --no-color web | grep -iE 'added [0-9]+ packages|ready in' | tail -3
docker inspect -f 'web StartedAt {{.State.StartedAt}}' "$("${COMPOSE[@]}" ps -q web)"
check_stack
curl -sS -o /dev/null -w 'API /healthz %{http_code}\n' "$API_URL/healthz"
curl -sS -o /dev/null -w 'Web / %{http_code}\n' "$WEB_URL/"
curl -sS -o /dev/null -w 'TEI %{http_code}\n' http://localhost:8080/health
curl -sS -o /dev/null -w 'S3Mock %{http_code}\n' http://localhost:9090/
