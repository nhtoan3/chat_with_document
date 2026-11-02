#!/usr/bin/env bash
# UT-014 — Use case hỏi đáp: không có tài liệu Sẵn sàng thì không gọi embedder
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-014 test_reports/UT-014/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_ask_usecase.py::test_no_ready_documents_does_not_call_embedder"
(cd backend && .venv/bin/pytest 'tests/unit/test_ask_usecase.py::test_no_ready_documents_does_not_call_embedder' -v)
