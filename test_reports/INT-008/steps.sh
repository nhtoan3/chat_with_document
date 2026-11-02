#!/usr/bin/env bash
# INT-008 — Lỗi tạm thời: thử lại 3 lần rồi transient_exhausted
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-008 test_reports/INT-008/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_transient_errors_retry_then_give_up (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_transient_errors_retry_then_give_up' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Dừng TEI"
"${COMPOSE[@]}" stop tei

echo "### Bước 4: Tải lên 1 PDF mẫu"
upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"

echo "### Bước 5: Theo dõi job mỗi 20 giây trong tối đa 6 phút"
for i in $(seq 1 18); do psql_q "SELECT now()::time(0) AS luc, j.state, j.attempt, j.next_run_at::time(0), d.status, d.error_code FROM ingestion_jobs j JOIN documents d ON d.id = j.document_id;"; s=$(curl -sS "$API_URL/api/v1/documents" | jq -r '.items[0].status'); [ "$s" = failed ] && break; sleep 20; done

echo "### Bước 6: Bật lại TEI"
"${COMPOSE[@]}" start tei; sleep 5; "${COMPOSE[@]}" ps tei
