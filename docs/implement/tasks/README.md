# Danh sách task phát triển — MVP "Chat với tài liệu"

> Nguồn: [Implement_plan.md](../Implement_plan.md) v0.4 — phạm vi chỉ gồm **F1 Xử lý PDF** và **F2 Hỏi đáp AI**.
> Mỗi task là một file `.md` độc lập, sẵn sàng đưa vào sprint. Cột **Phụ thuộc** cho biết task nào phải xong trước.

**Cách dùng:**

1. Chọn task có mọi task phụ thuộc đã xong.
2. Tạo nhánh theo tên ghi trong task.
3. Làm theo mục "Các bước thực hiện".
4. Đánh dấu "Tiêu chí hoàn thành" trong PR.
5. Cập nhật `Trạng thái` của task: `To do` → `In progress` → `Done`.

## Sprint 0 — Nền tảng (02/11 → 06/11/2026) — 8 task · 8 ngày

| Task | Tính năng | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-001 — Khởi tạo repo và cấu trúc mã](T-001-repo-skeleton.md) | — | OPS | 1 ngày | TL | — |
| [T-002 — Môi trường local bằng Docker Compose](T-002-docker-compose.md) | — | OPS | 1 ngày | TL | T-001 |
| [T-003 — CI tối thiểu](T-003-ci.md) | — | OPS | 0,5 ngày | TL | T-001 |
| [T-004 — Migration CSDL](T-004-db-migration.md) | — | DB | 0,5 ngày | BE1 | T-002 |
| [T-005 — Platform kernel: cấu hình, DB, lỗi, log, lưu trữ tệp](T-005-platform-kernel.md) | — | BE | 1 ngày | BE2 | T-004 |
| [T-006 — Môi trường AWS, giới hạn truy cập và script deploy](T-006-aws-environment.md) | — | OPS | 2 ngày | TL | T-003 |
| [T-007 — Frontend shell và API client](T-007-frontend-shell.md) | — | FE | 1 ngày | FE | T-001 |
| [T-008 — Golden set và script đánh giá câu trả lời](T-008-golden-eval.md) | — | QA | 1 ngày | BE1 + QA | T-002 |

## Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) — 14 task · 16,5 ngày

| Task | Tính năng | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-009 — API tải lên PDF (tối giản)](T-009-upload-api.md) | F1 — Xử lý PDF | BE | 1,5 ngày | BE1 | T-005 |
| [T-010 — Worker xử lý hàng đợi bằng PostgreSQL](T-010-worker-loop.md) | F1 — Xử lý PDF | BE | 1 ngày | BE1 | T-004 |
| [T-011 — Trích xuất văn bản PDF](T-011-pdf-extractor.md) | F1 — Xử lý PDF | BE | 1 ngày | BE1 | T-001 |
| [T-012 — Chunker theo trang](T-012-chunker.md) | F1 — Xử lý PDF | BE | 1 ngày | BE1 | T-011 |
| [T-013 — Pipeline ingestion: embedding và ghi chunk](T-013-ingest-pipeline.md) | F1 — Xử lý PDF | BE | 1,5 ngày | BE1 | T-010, T-012, T-002 |
| [T-014 — API danh sách tài liệu](T-014-documents-list-api.md) | F1 — Xử lý PDF | BE | 0,5 ngày | BE1 | T-009 |
| [T-015 — Màn hình Tài liệu: tải lên, danh sách, trạng thái](T-015-documents-ui.md) | F1 — Xử lý PDF | FE | 2 ngày | FE | T-007, T-009, T-014 |
| [T-016 — Bộ tệp mẫu và kiểm thử Xử lý PDF](T-016-pdf-tests.md) | F1 — Xử lý PDF | QA | 1 ngày | BE1 | T-009, T-013 |
| [T-017 — Truy xuất đoạn liên quan (vector)](T-017-vector-retrieval.md) | F2 — Hỏi đáp AI | BE | 1 ngày | BE2 | T-004 |
| [T-018 — System prompt](T-018-system-prompt.md) | F2 — Hỏi đáp AI | BE | 0,5 ngày | BE2 | — |
| [T-019 — Adapter gọi Claude (Anthropic API)](T-019-anthropic-adapter.md) | F2 — Hỏi đáp AI | BE | 1,5 ngày | BE2 | T-018 |
| [T-020 — API hỏi đáp](T-020-ask-api.md) | F2 — Hỏi đáp AI | BE | 1,5 ngày | BE2 | T-017, T-019, T-013 |
| [T-021 — Màn hình Hỏi đáp](T-021-ask-ui.md) | F2 — Hỏi đáp AI | FE | 1,5 ngày | FE | T-007, T-020 |
| [T-022 — Kiểm thử Hỏi đáp](T-022-ask-tests.md) | F2 — Hỏi đáp AI | QA | 1 ngày | BE2 | T-020 |

## Tuần ổn định & go-live (23/11 → 27/11/2026) — 2 task · 3,5 ngày

| Task | Tính năng | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-023 — Tinh chỉnh chất lượng câu trả lời](T-023-quality-tuning.md) | F2 — Hỏi đáp AI | BE | 2 ngày | BE1 + BE2 + QA | T-022, T-008 |
| [T-024 — UAT và go-live](T-024-uat-go-live.md) | — | OPS | 1,5 ngày | TL + PO + QA | T-023, T-015, T-021, T-006 |

## Chuỗi task quyết định ngày go-live

T-001 → T-002 → T-004 → T-010 → T-013 → T-020 (cần T-017, T-019) → T-022 → T-023 → T-024

**Tổng:** 24 task · 28 ngày công (ước lượng lý tưởng).
