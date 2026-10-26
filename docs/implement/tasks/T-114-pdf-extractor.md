# T-114 — Trích xuất văn bản PDF và phát hiện lỗi tệp

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-006 — Trạng thái xử lý tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-001](T-001-repo-skeleton.md) |
| Mở khóa cho | [T-115](T-115-chunker.md), [T-116](T-116-ingest-pipeline.md), [T-120](T-120-pdf-fixtures.md) |
| Nhánh git | `feat/T-114-pdf-extractor` |
| Trạng thái | `To do` |

## Mục tiêu

Lấy văn bản theo từng trang và phân loại chính xác các tệp không xử lý được.

## Phạm vi & đặc tả

**`documents/ingestion/pdf_extractor.py`:**

```python
@dataclass
class ExtractedPage: number: int; text: str
class ExtractionError(Exception): code: str  # encrypted_pdf | too_many_pages | corrupted | no_text_layer

def extract(pdf_bytes: bytes, max_pages: int) -> list[ExtractedPage]
```

1. `fitz.open(stream=pdf_bytes, filetype="pdf")`; ném ngoại lệ → `corrupted`.
2. `doc.needs_pass` → `encrypted_pdf`.
3. `doc.page_count > max_pages` → `too_many_pages`.
4. Với mỗi trang: `page.get_text("text", sort=True)` → `unicodedata.normalize("NFC")` → gộp dòng bị ngắt giữa câu (dòng không kết thúc bằng `.:;!?` và dòng sau bắt đầu bằng chữ thường) → bỏ khoảng trắng thừa.
5. Tổng ký tự / số trang < 30 → `no_text_layer`.

Hàm thuần, không I/O ngoài tham số → dễ unit test.

## Các bước thực hiện

1. Viết module.
2. Tạo fixture PDF (T-120).
3. Viết unit test.

## File cần tạo / sửa

- `backend/app/modules/documents/ingestion/pdf_extractor.py`

## Tiêu chí hoàn thành

- [ ] Đúng mã lỗi cho từng fixture lỗi; PDF văn bản trả đúng số trang và text tiếng Việt có dấu (NFC).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit test với bộ fixture của T-120.

## Ngoài phạm vi task này

- OCR cho PDF dạng ảnh scan.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.2, §3.4
- [User_Stories.md](../../requirements/User_Stories.md) AC-US-007-2, 3, 5
