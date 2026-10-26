# T-011 — Trích xuất văn bản PDF

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-012](T-012-chunker.md) |
| Nhánh git | `feat/T-011-pdf-extractor` |
| Trạng thái | `To do` |

## Mục tiêu

Lấy văn bản theo từng trang và phân loại các tệp không xử lý được.

## Phạm vi & đặc tả

**`documents/ingestion/pdf_extractor.py`:** `extract(pdf_bytes, max_pages) -> list[ExtractedPage(number, text)]`, ném `ExtractionError(code)`:

| Điều kiện | `code` |
|---|---|
| `fitz.open` lỗi | `corrupted` |
| `doc.needs_pass` | `encrypted_pdf` |
| `page_count > 300` | `too_many_pages` |
| Trung bình < 30 ký tự / trang | `no_text_layer` |

**Text từng trang:** `page.get_text("text", sort=True)` → `unicodedata.normalize("NFC")` → gộp dòng bị ngắt giữa câu → bỏ khoảng trắng thừa.

## Các bước thực hiện

1. Viết module (hàm thuần).
2. Viết unit test với fixture (T-016).

## File cần tạo / sửa

- `backend/app/modules/documents/ingestion/pdf_extractor.py`

## Tiêu chí hoàn thành

- [ ] Đúng mã lỗi cho từng fixture; PDF văn bản giữ đúng tiếng Việt có dấu.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit.

## Ngoài phạm vi task này

- OCR cho PDF scan.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.2
