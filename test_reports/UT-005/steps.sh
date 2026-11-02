#!/usr/bin/env bash
# UT-005 — Trích xuất PDF giữ trang và dấu tiếng Việt (NFC)
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-005 test_reports/UT-005/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_pdf_extractor.py::test_text_pdf_keeps_pages_and_vietnamese"
(cd backend && .venv/bin/pytest 'tests/unit/test_pdf_extractor.py::test_text_pdf_keeps_pages_and_vietnamese' -v)
