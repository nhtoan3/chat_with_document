#!/usr/bin/env bash
# UI-002 — Không có chuỗi giao diện viết cứng trong TSX
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs UI-002 test_reports/UI-002/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Tìm ký tự tiếng Việt có dấu trong các tệp TSX (bỏ dòng chú thích)"
python3 - <<'PY'
import pathlib, re
VN = re.compile('[À-ỹ]')
hits = []
for f in sorted(pathlib.Path('frontend/src').rglob('*.tsx')):
    for n, line in enumerate(f.read_text(encoding='utf-8').splitlines(), 1):
        code = line.strip()
        if code.startswith(('//', '/*', '*')):
            continue
        if True and VN.search(code):
            hits.append(f'{f}:{n}: {code}')
        if False and re.search(r'>\s*[A-Za-zÀ-ỹ][^<>{}]{2,}<', code):
            hits.append(f'{f}:{n}: {code}')
print('\n'.join(hits) if hits else 'KHÔNG CÓ kết quả')
print('so_dong_nghi_van:', len(hits))
PY

echo "### Bước 2: Tìm văn bản JSX thuần chữ giữa > và <"
python3 - <<'PY'
import pathlib, re
VN = re.compile('[À-ỹ]')
hits = []
for f in sorted(pathlib.Path('frontend/src').rglob('*.tsx')):
    for n, line in enumerate(f.read_text(encoding='utf-8').splitlines(), 1):
        code = line.strip()
        if code.startswith(('//', '/*', '*')):
            continue
        if False and VN.search(code):
            hits.append(f'{f}:{n}: {code}')
        if True and re.search(r'>\s*[A-Za-zÀ-ỹ][^<>{}]{2,}<', code):
            hits.append(f'{f}:{n}: {code}')
print('\n'.join(hits) if hits else 'KHÔNG CÓ kết quả')
print('so_dong_nghi_van:', len(hits))
PY
