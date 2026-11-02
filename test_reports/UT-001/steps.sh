#!/usr/bin/env bash
# UT-001 — Chunker: trang dài được chia trong giới hạn và có chồng lấp
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-001 test_reports/UT-001/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_chunker.py::test_long_page_is_split_within_limits_and_overlaps"
(cd backend && .venv/bin/pytest 'tests/unit/test_chunker.py::test_long_page_is_split_within_limits_and_overlaps' -v)
