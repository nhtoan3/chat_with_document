#!/usr/bin/env bash
# UT-013 — Use case hỏi đáp: trim câu hỏi, cho phép đúng 2000 ký tự
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-013 test_reports/UT-013/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Python và trạng thái stack localhost"
git rev-parse --short HEAD; backend/.venv/bin/python --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy tests/unit/test_ask_usecase.py::test_question_is_stripped_and_2000_chars_allowed"
(cd backend && .venv/bin/pytest 'tests/unit/test_ask_usecase.py::test_question_is_stripped_and_2000_chars_allowed' -v)
