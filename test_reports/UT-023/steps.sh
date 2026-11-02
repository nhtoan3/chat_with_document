#!/usr/bin/env bash
# UT-023 — Kiểm tra tệp phía client (số lượng, loại, dung lượng)
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-023 test_reports/UT-023/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Node và trạng thái stack localhost"
git rev-parse --short HEAD; node --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy npx vitest run src/features/documents/validate.test.ts"
(cd frontend && npx vitest run src/features/documents/validate.test.ts --reporter=verbose)
