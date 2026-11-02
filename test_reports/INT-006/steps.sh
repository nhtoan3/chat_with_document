#!/usr/bin/env bash
# INT-006 — Bộ tài liệu đạt giới hạn 50
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-006 test_reports/INT-006/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_documents.py::test_collection_full (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_documents.py::test_collection_full' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Chèn 49 tài liệu giả"
psql_q "INSERT INTO documents (filename, size_bytes, status, error_code, storage_key) SELECT 'gia-lap-' || g || '.pdf', 1, 'failed', 'corrupted', 'placeholder/' || g FROM generate_series(1, 49) g;"

echo "### Bước 4: Tải lên 2 PDF (49 + 2 > 50)"
upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf" "$FIXTURES/sample/De_xuat_hop_tac_Minh_Phat.pdf"

echo "### Bước 5: Tải lên 1 PDF (49 + 1 = 50)"
upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf"

echo "### Bước 6: Đếm tài liệu"
counts
