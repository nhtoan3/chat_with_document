#!/usr/bin/env bash
# UT-026 — API client: tiền tố, problem+json, lỗi mạng, thông điệp tiếng Việt
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-026 test_reports/UT-026/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Node và trạng thái stack localhost"
git rev-parse --short HEAD; node --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy npx vitest run src/shared/api/client.test.ts"
(cd frontend && npx vitest run src/shared/api/client.test.ts --reporter=verbose)
