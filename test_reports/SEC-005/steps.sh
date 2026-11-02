#!/usr/bin/env bash
# SEC-005 — An toàn khi tải tệp (tên tệp, loại tệp, kích thước)
# Chạy từ gốc repo: node frontend/e2e/run-cli.mjs SEC-005 test_reports/SEC-005/steps.sh
set -uo pipefail
source frontend/e2e/lib.sh

echo "### Bước 1: Kiểm tra stack localhost và dọn dữ liệu"
check_stack || exit 1
reset_data

echo "### Bước 2: Tải tệp với tên ../../etc/passwd.pdf"
curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/documents" -F "files=@$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf;filename=../../etc/passwd.pdf"

echo "### Bước 3: Tải tệp có tên 300 ký tự"
n=$(printf 'a%.0s' $(seq 1 296)).pdf; curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/documents" -F "files=@$FIXTURES/sample/De_xuat_hop_tac_Minh_Phat.pdf;filename=$n"

echo "### Bước 4: Tải tệp có tên Unicode dạng tổ hợp (NFD) Báo_cáo.pdf"
n=$(python3 -c "import unicodedata;print(unicodedata.normalize('NFD','Báo_cáo.pdf'))"); curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/documents" -F "files=@$FIXTURES/sample/Bien_ban_hop_doi_tac_15-09.pdf;filename=$n"

echo "### Bước 5: Kiểm tra tên và khóa lưu trữ trong CSDL"
psql_q "SELECT left(filename, 40) AS filename, length(filename) AS len, filename IS NFC NORMALIZED AS is_nfc, storage_key FROM documents;"

echo "### Bước 6: Tải fake.pdf và tệp 21 MB"
make_pdf big21mb "$DATA_DIR/qua_lon.pdf" >/dev/null; upload "$FIXTURES/fake.pdf" "$DATA_DIR/qua_lon.pdf"
