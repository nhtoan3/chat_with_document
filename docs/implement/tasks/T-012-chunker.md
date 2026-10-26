# T-012 — Chunker theo trang

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F1 — Xử lý PDF |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-011](T-011-pdf-extractor.md) |
| Mở khóa cho | [T-013](T-013-ingest-pipeline.md) |
| Nhánh git | `feat/T-012-chunker` |
| Trạng thái | `To do` |

## Mục tiêu

Chia văn bản thành đoạn khoảng 500 token để truy xuất.

## Phạm vi & đặc tả

**`documents/ingestion/chunker.py`:** `chunk_pages(pages, filename) -> list[Chunk(index, page_start, page_end, content, embed_text, token_count)]`.

- **Đếm token:** `tokenizers.Tokenizer.from_pretrained("BAAI/bge-m3")`, nạp một lần.
- **Không vượt ranh giới trang.** Ngoại lệ: trang < 80 token được gộp với trang sau.
- **Tách trang dài:** theo đoạn văn → theo câu. Mục tiêu 500 token, tối đa 800, chồng lấp 75 token.
- **`embed_text`** = `"{filename} — trang {page_start}: {content}"`.

## Các bước thực hiện

1. Viết module.
2. Viết unit test các ca biên.

## File cần tạo / sửa

- `backend/app/modules/documents/ingestion/chunker.py`

## Tiêu chí hoàn thành

- [ ] Không chunk nào > 800 token; PDF 50 trang chunk trong < 2 s.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit: trang dài, trang ngắn, trang trống.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.4
