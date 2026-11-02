# ADR-006: Chunk không vượt ranh giới trang

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` §3.4, §5; `backend/app/modules/documents/ingestion/chunker.py`; `docs/05-development/Implement_plan.md` §1

## Status

`Proposed` (theo SAD §5).

## Context

Trích dẫn cần chỉ đúng một trang, nên chunk không được vượt ranh giới trang (SAD §3.4).

## Decision

Chunk theo trang; trích dẫn ánh xạ phía server.

**Hiện trạng v0.4:**

- Đã có phần chunk theo trang (`chunker.py`): mục tiêu 500 token, tối đa 800, chồng lấp 75, đếm bằng tokenizer `bge-m3`. Trang dài tách theo đoạn văn rồi theo câu.
- Ngoại lệ: trang dưới 80 token gộp với trang kế tiếp, nên `page_start` có thể khác `page_end`.
- Tiền tố khi embedding: `"{filename} — trang {n}: "`. Cột `content` lưu văn bản không có tiền tố.
- **Không có phần "trích dẫn ánh xạ phía server"**: Plan §1 lược bỏ trích dẫn; không có bảng `citations`.

## Consequences

- `page_start` chỉ còn được đưa vào ngữ cảnh gửi LLM (`modules/qa/prompts.py:31`), không trả về người dùng. `page_end` được lưu nhưng không dùng khi truy xuất.
- Lý do gốc của quyết định (trích dẫn đúng trang) không phát huy ở v0.4 vì không có trích dẫn; dữ liệu trang vẫn được lưu trong `chunks`.
- Có test: `backend/tests/unit/test_chunker.py` (`docs/05-development/traceability.md`).

## Rejected alternatives

| Phương án | Lý do loại |
|---|---|
| Chunk cố định theo token, vượt trang | SAD §5 liệt kê; lý do suy từ SAD §3.4 là không chỉ được đúng một trang. Không có đánh giá riêng: [TBD] |
