#!/usr/bin/env bash
# UT-002 — Chunker: trang ngắn được gộp với trang sau
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-002 test_reports/UT-002/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_chunker.py::test_short_pages_are_merged_with_next"
(cd backend && .venv/bin/pytest 'tests/unit/test_chunker.py::test_short_pages_are_merged_with_next' -v)
