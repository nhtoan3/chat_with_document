# T-120 — Bộ tệp PDF lỗi mẫu và kiểm thử ingestion

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-007 — Báo lỗi tệp](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Kiểm thử |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-114](T-114-pdf-extractor.md), [T-116](T-116-ingest-pipeline.md) |
| Mở khóa cho | [T-122](T-122-retrieval-tests.md) |
| Nhánh git | `feat/T-120-pdf-fixtures` |
| Trạng thái | `To do` |

## Mục tiêu

Có bộ tệp mẫu cho từng loại lỗi và test chứng minh ingestion phân loại đúng.

## Phạm vi & đặc tả

`backend/tests/fixtures/pdfs/`:

| Tệp | Cách tạo | Mã lỗi mong đợi |
|---|---|---|
| `encrypted.pdf` | PyMuPDF `save(encryption=PDF_ENCRYPT_AES_256, user_pw='x')` | `encrypted_pdf` |
| `scanned.pdf` | Chèn 3 ảnh PNG, không có text | `no_text_layer` |
| `corrupted.pdf` | Cắt bỏ 50% byte cuối của một PDF hợp lệ | `corrupted` |
| `fake.pdf` | Tệp docx đổi đuôi | `not_pdf` (bị chặn từ API) |
| `301_pages.pdf` | **Tạo khi chạy test** (không commit) | `too_many_pages` |
| `sample/*.pdf` | 3 PDF tiếng Việt có văn bản (hợp đồng, đề xuất, biên bản giả lập) | — |

Script `tests/fixtures/make_pdfs.py` tạo lại toàn bộ fixture.

## Các bước thực hiện

1. Viết script tạo fixture.
2. Viết integration test chạy `run_ingest` cho từng tệp.

## File cần tạo / sửa

- `backend/tests/fixtures/make_pdfs.py`
- `backend/tests/fixtures/pdfs/*`
- `backend/tests/integration/test_ingest.py`

## Tiêu chí hoàn thành

- [ ] Mỗi tệp lỗi cho đúng `error_code`; tệp mẫu ở trạng thái `ready`.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [User_Stories.md](../../requirements/User_Stories.md) US-007
