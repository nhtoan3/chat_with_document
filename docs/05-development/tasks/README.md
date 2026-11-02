# Danh sách task phát triển — MVP "Chat với tài liệu"

> Nguồn: [Implement_plan.md](../Implement_plan.md) v0.4 — phạm vi chỉ gồm **F1 Xử lý PDF** và **F2 Hỏi đáp AI**.
> Mỗi task là một file `.md` độc lập, sẵn sàng đưa vào sprint. Cột **Phụ thuộc** cho biết task nào phải xong trước.

**Cách dùng:**

1. Chọn task có mọi task phụ thuộc đã xong.
2. Tạo nhánh theo tên ghi trong task.
3. Làm theo mục "Các bước thực hiện".
4. Đánh dấu "Tiêu chí hoàn thành" trong PR.
5. Cập nhật `Trạng thái` của task: `To do` → `In progress` → `Done`.

## Trạng thái hiện tại (rà soát 02/11/2026, commit `c02cc72`)

**Quy tắc:** chỉ tích tiêu chí có bằng chứng; có commit chưa đủ để coi là xong. Tiêu chí chung "Code đã được review, CI xanh, đã deploy lên môi trường AWS" chưa đạt ở mọi task: chưa có review, job `build` của CI đang đỏ và chưa dựng AWS. Vì vậy **chưa task nào `Done`**.

**CI** (GitHub Actions, 27 lần chạy đều `failure`): ở 6 lần gần nhất, job `backend` và `frontend` xanh; job `build` lỗi ở bước `configure-aws-credentials`.

**Test chạy lại ngày 02/11:** ruff, mypy, eslint, tsc sạch; unit backend 31/31 và vitest 15/15 pass. Docker tắt nên integration chỉ dựa vào kết quả CI.

| Task | Trạng thái | Tiêu chí đạt | Bằng chứng | Còn lại |
|---|---|---|---|---|
| T-001 | `In progress` | 2/4 | CI `c02cc72`; lint và unit chạy lại 02/11; gọi thử `/healthz` | Backend chưa có lock file (chỉ có `frontend/package-lock.json`) |
| T-002 | `In progress` | 2/4 | Chạy thử 26/10; E2E 31/10 trên stack thật | Chưa ghi nhận phép thử `curl /embed` (vector 1024 chiều) |
| T-003 | `In progress` | 0/2 | Job `backend`, `frontend` xanh trên `main` | Chưa có PR mẫu; chưa thử chặn merge; job `build` đỏ |
| T-004 | `In progress` | 1/3 | `0001_init.py`; CI chạy `alembic upgrade head` | Chưa có bằng chứng `downgrade base` |
| T-005 | `In progress` | 2/4 | `test_app_error_is_problem_json`; log JSON khi gọi `/healthz` ngày 02/11 | Chưa có test `S3Storage` với S3 thật hoặc S3Mock |
| T-006 | `In progress` | 0/4 | Có bộ script và hướng dẫn | Chưa dựng AWS, chưa kiểm tra nào |
| T-007 | `In progress` | 1/3 | Quét TSX ngày 02/11: tiếng Việt chỉ còn trong một comment | Chưa kiểm tra layout 1440 / 1024 px (UI-*) |
| T-008 | `In progress` | 0/2 | Có script và 6 câu mẫu | Chưa chạy với Claude thật; chưa có bằng chứng đã gửi template cho BD |
| T-009 | `In progress` | 0/2 | `test_documents.py` xanh trên CI | Chưa đo RAM khi tải 10 × 20 MB |
| T-010 | `In progress` | 1/3 | `test_two_workers_never_claim_the_same_job` | Việc thu hồi mới test bằng giả lập; chưa kill worker thật (OPS-007) |
| T-011 | `In progress` | 1/2 | `test_pdf_extractor.py`, `test_bad_pdfs_fail_with_code` | Chỉ còn tiêu chí chung |
| T-012 | `In progress` | 0/2 | `test_chunker.py` kiểm tra giới hạn đoạn | Chưa đo PDF 50 trang < 2 s |
| T-013 | `In progress` | 1/4 | `test_per_file_errors_do_not_block_valid_files` | Chưa đo 50 trang trên AWS; retry mới test bằng `FakeEmbedder`, chưa tắt TEI thật |
| T-014 | `In progress` | 1/2 | `test_upload_three_valid_pdfs_then_ingest` | Chỉ còn tiêu chí chung |
| T-015 | `In progress` | 2/3 | E2E-001, E2E-002 (31/10) | Chỉ còn tiêu chí chung |
| T-016 | `In progress` | 1/2 | Job `backend` xanh ở `c02cc72` | Chỉ còn tiêu chí chung |
| T-017 | `In progress` | 1/3 | `test_retrieval_ranks_relevant_chunk_and_skips_unready` | Chưa đo < 100 ms với 30.000 chunk |
| T-018 | `In progress` | 0/2 | Đã có `qa/prompts.py` | PO chưa duyệt nội dung |
| T-019 | `In progress` | 0/3 | `test_failures_map_to_llm_unavailable` có lỗi 500 | Chưa test lỗi 529; log của adapter chưa có latency |
| T-020 | `In progress` | 3/4 | `test_ask.py` xanh trên CI, dùng LLM giả | Chưa thử với Claude thật |
| T-021 | `In progress` | 2/3 | E2E-004, 005, 007, 008 (31/10), giả lập `/ask` | Chưa thử với Claude thật (E2E-005) |
| T-022 | `In progress` | 1/2 | Job `backend`, `frontend` xanh ở `c02cc72` | Chưa chạy test `live` |
| T-023 | `To do` | 0/2 | Chưa có commit | Chờ golden set và khóa API |
| T-024 | `In progress` | 0/3 | Đã soạn mẫu UAT và hướng dẫn sử dụng | UAT, go / no-go, go-live |

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

## Sửa lỗi sau kiểm thử (từ `docs/07-verification/test-report.md`)

| Task | Tính năng | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-025 — Bổ sung thông điệp `not_found` và test đồng bộ mã lỗi ↔ `vi.json`](T-025-not-found-message.md) | Nền tảng | BE + FE | 0,5 ngày | FE | T-005, T-007 |

## Chuỗi task quyết định ngày go-live

T-001 → T-002 → T-004 → T-010 → T-013 → T-020 (cần T-017, T-019) → T-022 → T-023 → T-024

**Tổng:** 24 task · 28 ngày công (ước lượng lý tưởng).
