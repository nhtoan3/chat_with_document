#!/usr/bin/env bash
# INT-009 — Hai worker không lấy trùng một job
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-009 test_reports/INT-009/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_two_workers_never_claim_the_same_job (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_two_workers_never_claim_the_same_job' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Xác nhận có 2 worker"
"${COMPOSE[@]}" ps worker

echo "### Bước 4: Tạo và tải lên 10 PDF (tên khác nhau)"
for i in $(seq -w 1 10); do cp "$FIXTURES/sample/De_xuat_hop_tac_Minh_Phat.pdf" "$DATA_DIR/de_xuat_$i.pdf"; done; upload "$DATA_DIR"/de_xuat_*.pdf

echo "### Bước 5: Chờ xử lý và kiểm tra mỗi tài liệu chỉ có 1 job, 1 lần thử, chunk không trùng"
wait_idle 300; psql_q "SELECT d.filename, d.status, count(DISTINCT j.id) AS jobs, max(j.attempt) AS attempt, count(c.id) AS chunks, count(DISTINCT c.chunk_index) AS chunk_idx FROM documents d JOIN ingestion_jobs j ON j.document_id = d.id LEFT JOIN chunks c ON c.document_id = d.id GROUP BY 1,2 ORDER BY 1;"

echo "### Bước 6: Xem log 2 worker"
"${COMPOSE[@]}" logs --no-color --tail 60 worker
