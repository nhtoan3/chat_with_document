#!/usr/bin/env bash
# OPS-001 — make dev dựng đủ stack healthy
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs OPS-001 test_reports/OPS-001/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Khởi động stack"
make dev

echo "### Bước 2: Chờ TEI healthy (tối đa 15 phút)"
for i in $(seq 1 90); do s=$(docker inspect -f '{{.State.Health.Status}}' $("${COMPOSE[@]}" ps -q tei)); echo "tei: $s"; [ "$s" = healthy ] && break; sleep 10; done

echo "### Bước 3: Liệt kê dịch vụ"
"${COMPOSE[@]}" ps -a

echo "### Bước 4: Gọi từng endpoint"
check_stack; curl -sS -o /dev/null -w 'TEI %{http_code}\n' http://localhost:8080/health; curl -sS -o /dev/null -w 'S3Mock %{http_code}\n' http://localhost:9090/
