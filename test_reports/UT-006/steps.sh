#!/usr/bin/env bash
# UT-006 — Trích xuất PDF từ chối tệp mã hóa, scan, hỏng
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-006 test_reports/UT-006/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_pdf_extractor.py::test_rejected_files"
(cd backend && .venv/bin/pytest 'tests/unit/test_pdf_extractor.py::test_rejected_files' -v)
