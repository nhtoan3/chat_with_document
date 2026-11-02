#!/usr/bin/env bash
# UT-004 — Chunker: bỏ trang rỗng, văn bản embed có tiền tố
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-004 test_reports/UT-004/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_chunker.py::test_empty_pages_skipped_and_embed_text_has_prefix"
(cd backend && .venv/bin/pytest 'tests/unit/test_chunker.py::test_empty_pages_skipped_and_embed_text_has_prefix' -v)
