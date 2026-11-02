#!/usr/bin/env bash
# PERF-003 — Tải lô 10 × 20 MB: RAM api tăng ≤ 100 MB
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs PERF-003 test_reports/PERF-003/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Sinh 10 tệp 20 MB"
for i in $(seq -w 1 10); do make_pdf big20mb "$DATA_DIR/lon_$i.pdf" >/dev/null; done; ls -lh "$DATA_DIR"

echo "### Bước 3: Đo RAM nền của api"
id=$("${COMPOSE[@]}" ps -q api); docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' "$id"

echo "### Bước 4: Tải lên trong khi lấy mẫu RAM mỗi giây"
id=$("${COMPOSE[@]}" ps -q api); (for i in $(seq 1 40); do docker stats --no-stream --format '{{.MemUsage}}' "$id"; done > "$DATA_DIR/mem.txt") & sp=$!; upload "$DATA_DIR"/lon_*.pdf; sleep 3; kill $sp 2>/dev/null; wait $sp 2>/dev/null; true

echo "### Bước 5: Tính mức tăng RAM"
python3 - "$DATA_DIR/mem.txt" <<'PY'
import re,sys
v=[]
for l in open(sys.argv[1]):
    m=re.match(r'([\d.]+)(KiB|MiB|GiB)',l.strip())
    if m: v.append(float(m[1])*{'KiB':1/1024,'MiB':1,'GiB':1024}[m[2]])
print('mau:',len(v),'min_MiB:',round(min(v),1),'max_MiB:',round(max(v),1),'tang_MiB:',round(max(v)-min(v),1))
PY
