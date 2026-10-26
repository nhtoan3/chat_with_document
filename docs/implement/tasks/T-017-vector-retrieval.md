# T-017 — Truy xuất đoạn liên quan (vector)

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F2 — Hỏi đáp AI |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-004](T-004-db-migration.md) |
| Mở khóa cho | [T-020](T-020-ask-api.md) |
| Nhánh git | `feat/T-017-vector-retrieval` |
| Trạng thái | `To do` |

## Mục tiêu

Tìm các đoạn liên quan nhất tới câu hỏi trong các tài liệu Sẵn sàng.

## Phạm vi & đặc tả

**Port** (`qa/ports.py`): `RetrievalPort.search(qvec, top_n) -> list[RetrievedChunk(filename, page_start, content, sim)]`.

**Adapter** (`qa/adapters/pg_retrieval.py`):

```sql
SET LOCAL hnsw.ef_search = 80;
SELECT d.filename, c.page_start, c.content, 1 - (c.embedding <=> :qvec) AS sim
FROM chunks c JOIN documents d ON d.id = c.document_id
WHERE d.status = 'ready'
ORDER BY c.embedding <=> :qvec
LIMIT :top_n;
```

Có thể phát triển song song với F1, dùng chunk giả lập trong test.

## Các bước thực hiện

1. Viết port và adapter.
2. Viết test.

## File cần tạo / sửa

- `backend/app/modules/qa/ports.py`
- `backend/app/modules/qa/adapters/pg_retrieval.py`

## Tiêu chí hoàn thành

- [ ] Tài liệu không `ready` không xuất hiện trong kết quả.
- [ ] < 100 ms với 30.000 chunk.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Integration (Testcontainers + vector giả lập).

## Ngoài phạm vi task này

- Full-text search.

## Tham chiếu

- [SAD.md](../../design/SAD.md) ADR-003
