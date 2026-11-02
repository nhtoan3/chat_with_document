#!/usr/bin/env bash
# UT-025 — Render Markdown an toàn (chống XSS)
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-025 test_reports/UT-025/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Ghi nhận môi trường: commit, phiên bản Node và trạng thái stack localhost"
git rev-parse --short HEAD; node --version; check_stack || echo '(stack chưa chạy — không ảnh hưởng unit test)'

echo "### Bước 2: Chạy npx vitest run src/features/ask/markdown.test.ts"
(cd frontend && npx vitest run src/features/ask/markdown.test.ts --reporter=verbose)
