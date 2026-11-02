#!/usr/bin/env bash
# PERF-001 — PDF văn bản 50 trang Sẵn sàng ≤ 60 giây
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs PERF-001 test_reports/PERF-001/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Sinh PDF 50 trang"
make_pdf pages50 "$DATA_DIR/hop_dong_50_trang.pdf"

echo "### Bước 3: Tải lên và chờ"
date +%T; upload "$DATA_DIR/hop_dong_50_trang.pdf"; wait_idle 600; date +%T

echo "### Bước 4: Đọc số đo trong CSDL"
psql_q "SELECT d.filename, d.pages, d.status, round(extract(epoch FROM d.ready_at - d.uploaded_at)::numeric, 1) AS seconds_to_ready, j.processing_ms FROM documents d JOIN ingestion_jobs j ON j.document_id = d.id;"
