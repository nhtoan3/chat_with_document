#!/usr/bin/env bash
# SEC-004 — Chống XSS trong câu trả lời
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs SEC-004 test_reports/SEC-004/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: (CLI) Chạy npx vitest run src/features/ask/markdown.test.ts"
(cd frontend && npx vitest run src/features/ask/markdown.test.ts --reporter=verbose)
