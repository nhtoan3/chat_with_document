# T-121 — Truy xuất vector (PgRetrieval)

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-008 — Mọi tài liệu Sẵn sàng là nguồn trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 1 (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-116](T-116-ingest-pipeline.md) |
| Mở khóa cho | [T-122](T-122-retrieval-tests.md), [T-203](T-203-ask-question-usecase.md) |
| Nhánh git | `feat/T-121-vector-retrieval` |
| Trạng thái | `To do` |

## Mục tiêu

Tìm `top_n` đoạn liên quan nhất tới câu hỏi trong các tài liệu đang Sẵn sàng (ADR-003, bản MVP chỉ dùng vector).

## Phạm vi & đặc tả

**Port** (`qa/ports.py`):

```python
@dataclass
class RetrievedChunk: chunk_id; document_id; filename; page_start; page_end; content; sim: float
class RetrievalPort(Protocol):
    async def search(self, collection_id: UUID, qvec: list[float], top_n: int) -> list[RetrievedChunk]: ...
```

**Adapter** (`qa/adapters/pg_retrieval.py`), trong một transaction:

```sql
SET LOCAL hnsw.ef_search = 80;
SELECT c.id, c.document_id, d.filename, c.page_start, c.page_end, c.content,
       1 - (c.embedding <=> :qvec) AS sim
FROM chunks c JOIN documents d ON d.id = c.document_id
WHERE d.collection_id = :cid AND d.status = 'ready'
ORDER BY c.embedding <=> :qvec
LIMIT :top_n;
```

Truyền `qvec` dưới dạng `pgvector` (thư viện `pgvector.asyncpg` đăng ký kiểu dữ liệu).

## Các bước thực hiện

1. Thêm thư viện `pgvector`.
2. Viết port và adapter.
3. Viết test (T-122).

## File cần tạo / sửa

- `backend/app/modules/qa/ports.py`
- `backend/app/modules/qa/adapters/pg_retrieval.py`

## Tiêu chí hoàn thành

- [ ] Tài liệu không ở trạng thái `ready` không bao giờ xuất hiện trong kết quả (AC-US-008-1).
- [ ] Truy vấn < 100 ms với 30.000 chunk.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Xem T-122.

## Ngoài phạm vi task này

- Full-text search và RRF (chỉ thêm nếu golden set cho thấy cần — ADR-003).

## Tham chiếu

- [SAD.md](../../design/SAD.md) §3.2.1 bước 5, ADR-003
- [User_Stories.md](../../requirements/User_Stories.md) US-008
