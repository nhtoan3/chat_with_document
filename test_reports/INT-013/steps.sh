#!/usr/bin/env bash
# INT-013 — Truy xuất xếp hạng đúng đoạn và bỏ tài liệu chưa Sẵn sàng
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs INT-013 test_reports/INT-013/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Chạy test tự động tests/integration/test_ask.py::test_retrieval_ranks_relevant_chunk_and_skips_unready (Testcontainers)"
(cd backend && .venv/bin/pytest 'tests/integration/test_ask.py::test_retrieval_ranks_relevant_chunk_and_skips_unready' -v)

echo "### Bước 2: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 3: Nạp 3 PDF mẫu và chờ Sẵn sàng"
seed_samples; wait_idle 300

echo "### Bước 4: Embed câu hỏi \"Mức phạt khi chậm thanh toán là bao nhiêu?\" bằng TEI và lấy top-3 chunk theo cosine"
curl -sS http://localhost:8080/embed -H 'content-type: application/json' -d '{"inputs":"Mức phạt khi chậm thanh toán là bao nhiêu?"}' | jq -c '.[0]' > "$DATA_DIR/qvec.json"
psql_q "SELECT d.filename, c.page_start, round((1 - (c.embedding <=> '$(cat "$DATA_DIR/qvec.json")'::vector))::numeric, 3) AS similarity FROM chunks c JOIN documents d ON d.id = c.document_id WHERE d.status = 'ready' ORDER BY c.embedding <=> '$(cat "$DATA_DIR/qvec.json")'::vector LIMIT 3;"

echo "### Bước 5: Xác nhận câu truy vấn truy xuất có lọc status = 'ready'"
grep -n "status = 'ready'" backend/app/modules/qa/adapters/pg_retrieval.py
