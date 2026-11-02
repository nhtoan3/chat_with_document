#!/usr/bin/env bash
# UT-027 — Mọi mã lỗi đều có thông điệp tiếng Việt trong vi.json
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UT-027 test_reports/UT-027/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Liệt kê mã lỗi phía backend (ERRORS + mã ingestion)"
(cd backend && .venv/bin/python -c "from app.platform.errors import ERRORS; print(sorted(ERRORS))"); echo 'ingestion: encrypted_pdf no_text_layer too_many_pages corrupted transient_exhausted'

echo "### Bước 2: So sánh với errors trong vi.json"
(cd backend && .venv/bin/python - <<'PY'
import json
from app.platform.errors import ERRORS
codes = set(ERRORS) | {'encrypted_pdf','no_text_layer','too_many_pages','corrupted','transient_exhausted'}
vi = json.load(open('../frontend/src/shared/i18n/vi.json', encoding='utf-8'))['errors']
print('THIẾU:', sorted(codes - set(vi)))
print('Thừa (chỉ phía frontend, chấp nhận được):', sorted(set(vi) - codes))
PY
)
