#!/usr/bin/env bash
# OPS-009 — Truy vấn số liệu pilot chạy được
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs OPS-009 test_reports/OPS-009/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Tạo vài dòng qa_log (không cần khóa API)"
seed_samples; wait_idle 300; for q in 'Câu 1' 'Câu 2' 'Câu 3'; do ask "$q" >/dev/null; done; psql_q "SELECT count(*) FROM qa_log;"

echo "### Bước 3: Chạy truy vấn số liệu của T-024"
psql_q "SELECT date_trunc('week', created_at) AS tuan, count(*) AS so_cau_hoi, percentile_cont(0.9) WITHIN GROUP (ORDER BY latency_ms) AS p90_ms FROM qa_log GROUP BY 1 ORDER BY 1;"
