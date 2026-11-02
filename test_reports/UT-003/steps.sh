#!/usr/bin/env bash
# UT-003 — Chunker: chunk không trải qua hai trang thường
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-003 test_reports/UT-003/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_chunker.py::test_chunks_never_span_two_normal_pages"
(cd backend && .venv/bin/pytest 'tests/unit/test_chunker.py::test_chunks_never_span_two_normal_pages' -v)
