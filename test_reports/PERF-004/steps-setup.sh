#!/usr/bin/env bash
# PERF-004 — bước 1 (CLI), tách từ script gợi ý theo ghi chú của test case
set -uo pipefail
source frontend/e2e/lib.sh
echo "### Bước 1: (CLI) Chuẩn bị: nạp tài liệu, khởi động lại api với override"
check_stack || exit 1; reset_data; seed_samples; wait_idle 300
printf 'services:\n  api:\n    environment:\n      ANTHROPIC_API_KEY: sk-ant-dummy\n      ANTHROPIC_BASE_URL: http://10.255.255.1:81\n' > "$DATA_DIR/compose.override.yml"
docker compose -f docker-compose.yml -f "$DATA_DIR/compose.override.yml" up -d --force-recreate api; for i in $(seq 1 30); do curl -fsS "$API_URL/healthz" >/dev/null && break; sleep 2; done; echo healthz OK
