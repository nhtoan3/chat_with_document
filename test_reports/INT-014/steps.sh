#!/usr/bin/env bash
# INT-014 — Hỏi đáp thành công và qa_log không chứa nội dung
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-014 test_reports/INT-014/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_ask.py::test_ask_returns_answer_and_logs_without_content (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_ask.py::test_ask_returns_answer_and_logs_without_content' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Nạp 3 PDF mẫu"
seed_samples; wait_idle 300

echo "### Bước 4: Hỏi \"Điều khoản tạm ứng trong hợp đồng khung với ABC là gì?\""
ask 'Điều khoản tạm ứng trong hợp đồng khung với ABC là gì?'

echo "### Bước 5: Kiểm tra cột và dòng mới nhất của qa_log"
psql_q "SELECT column_name FROM information_schema.columns WHERE table_name = 'qa_log' ORDER BY ordinal_position;"; psql_q "SELECT * FROM qa_log ORDER BY id DESC LIMIT 1;"
