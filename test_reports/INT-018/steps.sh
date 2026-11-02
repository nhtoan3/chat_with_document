#!/usr/bin/env bash
# INT-018 — LLM lỗi → 503 ai_unavailable và qa_log status error
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-018 test_reports/INT-018/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_ask.py::test_llm_failure_is_503_and_logged (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_ask.py::test_llm_failure_is_503_and_logged' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Nạp PDF mẫu"
seed_samples; wait_idle 300

echo "### Bước 4: Khởi động lại api với khóa API không hợp lệ"
ANTHROPIC_API_KEY=sk-ant-invalid "${COMPOSE[@]}" up -d --force-recreate api; for i in $(seq 1 30); do curl -fsS "$API_URL/healthz" >/dev/null && break; sleep 2; done; echo healthz OK

echo "### Bước 5: Hỏi một câu"
ask 'Mức phạt khi chậm thanh toán là bao nhiêu?'

echo "### Bước 6: Kiểm tra qa_log"
psql_q "SELECT id, status, latency_ms, chunk_count FROM qa_log ORDER BY id DESC LIMIT 1;"

echo "### Bước 7: Khôi phục api với cấu hình gốc"
"${COMPOSE[@]}" up -d --force-recreate api; sleep 5; check_stack
