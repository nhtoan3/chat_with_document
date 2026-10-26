# T-115 — Chunker theo trang

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-006 — Trạng thái xử lý tài liệu](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-114](T-114-pdf-extractor.md) |
| Mở khóa cho | [T-116](T-116-ingest-pipeline.md) |
| Nhánh git | `feat/T-115-chunker` |
| Trạng thái | `To do` |

## Mục tiêu

Chia văn bản thành các đoạn khoảng 500 token không vượt ranh giới trang, để trích dẫn luôn chỉ đúng trang (ADR-006).

## Phạm vi & đặc tả

**`documents/ingestion/chunker.py`:**

```python
@dataclass
class Chunk: index: int; page_start: int; page_end: int; content: str; embed_text: str; token_count: int
def chunk_pages(pages: list[ExtractedPage], filename: str, target=500, max_=800, overlap=75) -> list[Chunk]
```

- **Đếm token:** `tokenizers.Tokenizer.from_pretrained("BAAI/bge-m3")`, nạp **một lần** khi khởi động worker.
- **Không vượt ranh giới trang.** Ngoại lệ: trang < 80 token được gộp với trang kế tiếp; khi đó `page_end = trang sau`.
- **Tách trang dài:** theo đoạn văn (`\n\n`), rồi theo câu (regex `(?<=[.!?…])\s+`). Gom tới khoảng `target` token; không vượt `max_`. Chunk mới bắt đầu bằng 75 token cuối của chunk trước (chồng lấp).
- **Trường dữ liệu:** `content` = văn bản gốc của chunk (lưu DB, gửi cho LLM); `embed_text = f"{filename} — trang {page_start}: {content}"` (chỉ dùng để embed).
- Trang trống bị bỏ qua.

## Các bước thực hiện

1. Viết module.
2. Viết unit test với các ca biên.

## File cần tạo / sửa

- `backend/app/modules/documents/ingestion/chunker.py`

## Tiêu chí hoàn thành

- [ ] Không chunk nào > 800 token.
- [ ] Chunk chỉ có `page_start ≠ page_end` khi gộp trang ngắn.
- [ ] PDF 50 trang được chunk trong < 2 s.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit: 1 trang dài 3.000 token; 3 trang ngắn 30 token; trang trống; văn bản tiếng Việt.

## Ngoài phạm vi task này

- Chunk theo ngữ nghĩa (semantic chunking).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.4, ADR-006
