#!/usr/bin/env bash
# PERF-004 — bước 4 (CLI), tách từ script gợi ý
set -uo pipefail
source frontend/e2e/lib.sh
echo "### Bước 4: (CLI) Khôi phục api"
"${COMPOSE[@]}" up -d --force-recreate api; sleep 5; check_stack; reset_data
