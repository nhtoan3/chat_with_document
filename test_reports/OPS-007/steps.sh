#!/usr/bin/env bash
# OPS-007 — Khởi động lại worker khi đang xử lý: job được thu hồi
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs OPS-007 test_reports/OPS-007/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Sinh PDF 50 trang và tải lên"
make_pdf pages50 "$DATA_DIR/dai.pdf"; upload "$DATA_DIR/dai.pdf"

echo "### Bước 3: Chờ job vào running rồi kill cả 2 worker"
for i in $(seq 1 60); do s=$(psql_q "SELECT state FROM ingestion_jobs;" | sed -n 3p | tr -d ' '); echo "job: $s"; [ "$s" = running ] && break; sleep 1; done; "${COMPOSE[@]}" kill worker; psql_q "SELECT state, attempt, started_at FROM ingestion_jobs;"

echo "### Bước 4: Giả lập job đã treo quá 10 phút rồi bật lại worker"
psql_q "UPDATE ingestion_jobs SET started_at = now() - interval '11 minutes' WHERE state = 'running';"; "${COMPOSE[@]}" start worker

echo "### Bước 5: Chờ thu hồi và xử lý xong (tối đa 3 phút)"
wait_idle 240; "${COMPOSE[@]}" logs --no-color --since 5m worker | grep -i stale || true

echo "### Bước 6: Kiểm tra không trùng lặp"
psql_q "SELECT count(DISTINCT d.id) AS docs, count(DISTINCT j.id) AS jobs, count(c.id) AS chunks, count(DISTINCT c.chunk_index) AS chunk_idx FROM documents d JOIN ingestion_jobs j ON j.document_id = d.id LEFT JOIN chunks c ON c.document_id = d.id;"
