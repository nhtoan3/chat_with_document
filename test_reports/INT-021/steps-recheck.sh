#!/usr/bin/env bash
# INT-021 — workaround lỗi script test case: `head -30` trong script gợi ý cắt mất dòng <div id="root">.
set -uo pipefail
source frontend/e2e/lib.sh
echo "### Bước 2b: Gọi trang web gốc và tìm phần tử root trong toàn bộ HTML"
curl -sS -o /dev/null -w 'Web / HTTP %{http_code}\n' "$WEB_URL/"
curl -sS "$WEB_URL/" | grep -n 'id="root"'
