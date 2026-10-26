# Danh sách task phát triển — MVP "Chat với tài liệu"

> Nguồn: [Implement_plan.md](../Implement_plan.md) v0.3 · [Dev_Tasks.md](../Dev_Tasks.md) · [User_Stories.md](../../requirements/User_Stories.md) v0.2
> Mỗi task là một file `.md` độc lập, sẵn sàng đưa vào sprint. Cột **Phụ thuộc** cho biết task nào phải xong trước.

**Cách dùng:**

1. Chọn task có mọi task phụ thuộc đã xong.
2. Tạo nhánh theo tên ghi trong task.
3. Làm theo mục "Các bước thực hiện".
4. Đánh dấu "Tiêu chí hoàn thành" trong PR.
5. Cập nhật `Trạng thái` của task: `To do` → `In progress` → `Done`.

## Sprint 0 (02/11 → 06/11/2026) — 10 task · 13,5 ngày

| Task | Story | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-001 — Khởi tạo repo và cấu trúc mã](T-001-repo-skeleton.md) | — | OPS | 1 ngày | TL | — |
| [T-002 — Môi trường local bằng Docker Compose](T-002-docker-compose.md) | — | OPS | 1 ngày | TL | T-001 |
| [T-003 — CI trên GitHub Actions](T-003-ci-pipeline.md) | — | OPS | 1 ngày | TL | T-001 |
| [T-004 — Migration CSDL baseline cho MVP](T-004-db-baseline.md) | — | DB | 1,5 ngày | BE1 | T-002 |
| [T-005 — Platform kernel: cấu hình, DB, lỗi, log, audit, lưu trữ tệp](T-005-platform-kernel.md) | — | BE | 2 ngày | BE2 | T-001, T-004 |
| [T-006 — Môi trường AWS và script deploy](T-006-aws-environment.md) | — | OPS | 2,5 ngày | TL | T-003 |
| [T-007 — Frontend shell, design system và API client](T-007-frontend-shell.md) | — | FE | 2 ngày | FE | T-001 |
| [T-008 — PoC AR-01: đo độ trễ LLM](T-008-poc-llm-latency.md) | — | BE | 1 ngày | BE2 | T-001 |
| [T-009 — PoC AR-02: đo thông lượng embedding trên CPU](T-009-poc-embedding.md) | — | BE | 0,5 ngày | BE1 | T-002 |
| [T-010 — Định dạng golden set và script đánh giá](T-010-golden-eval.md) | — | QA | 1 ngày | BE1 + QA | T-002 |

## Sprint 1 (09/11 → 20/11/2026) — 25 task · 23,5 ngày

| Task | Story | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-101 — Phiên đăng nhập và CSRF](T-101-session-csrf.md) | US-001 | BE | 1,5 ngày | BE2 | T-004, T-005 |
| [T-102 — API đăng nhập, đăng xuất và /me](T-102-auth-api.md) | US-001 | BE | 1,5 ngày | BE2 | T-101 |
| [T-103 — CLI quản trị tài khoản](T-103-admin-cli.md) | US-001 | BE | 0,5 ngày | BE2 | T-102 |
| [T-104 — Màn hình đăng nhập, route guard và đăng xuất](T-104-login-ui.md) | US-001 | FE | 1,5 ngày | FE | T-007, T-102 |
| [T-105 — Kiểm thử tích hợp cho xác thực](T-105-auth-tests.md) | US-001 | QA | 0,5 ngày | BE2 | T-102 |
| [T-106 — Endpoint tải tệp PDF bằng presigned URL](T-106-file-endpoint.md) | US-002 | BE | 0,5 ngày | BE1 | T-101, T-110 |
| [T-107 — Kiểm thử truy cập tệp](T-107-file-access-tests.md) | US-002 | QA | 0,25 ngày | BE1 | T-106, T-103 |
| [T-108 — Repository hội thoại có kiểm tra chủ sở hữu](T-108-conversation-owner-repo.md) | US-003 | BE | 0,5 ngày | BE2 | T-004, T-101 |
| [T-109 — Kiểm thử quyền sở hữu hội thoại](T-109-conversation-rbac-tests.md) | US-003 | QA | 0,25 ngày | BE2 | T-108 |
| [T-110 — API tải lên PDF](T-110-upload-api.md) | US-005 | BE | 2 ngày | BE1 | T-005, T-101 |
| [T-111 — Vùng kéo-thả và tiến trình tải lên](T-111-upload-ui.md) | US-005 | FE | 2 ngày | FE | T-007, T-110 |
| [T-112 — Kiểm thử API tải lên](T-112-upload-tests.md) | US-005 | QA | 0,5 ngày | BE1 | T-110 |
| [T-113 — Worker xử lý hàng đợi bằng PostgreSQL](T-113-worker-loop.md) | US-006 | BE | 1 ngày | BE1 | T-004 |
| [T-114 — Trích xuất văn bản PDF và phát hiện lỗi tệp](T-114-pdf-extractor.md) | US-006 | BE | 1 ngày | BE1 | T-001 |
| [T-115 — Chunker theo trang](T-115-chunker.md) | US-006 | BE | 1 ngày | BE1 | T-114 |
| [T-116 — Pipeline ingestion: embedding và ghi chunk](T-116-ingest-pipeline.md) | US-006 | BE | 1,5 ngày | BE1 | T-113, T-114, T-115, T-002 |
| [T-117 — API danh sách tài liệu](T-117-documents-list-api.md) | US-006 | BE | 0,5 ngày | BE1 | T-110 |
| [T-118 — Màn hình danh sách tài liệu và tự cập nhật trạng thái](T-118-documents-list-ui.md) | US-006 | FE | 1,5 ngày | FE | T-007, T-117 |
| [T-119 — Hiển thị lỗi xử lý tệp](T-119-file-errors-ui.md) | US-007 | FE | 0,5 ngày | FE | T-118 |
| [T-120 — Bộ tệp PDF lỗi mẫu và kiểm thử ingestion](T-120-pdf-fixtures.md) | US-007 | QA | 0,5 ngày | BE1 | T-114, T-116 |
| [T-121 — Truy xuất vector (PgRetrieval)](T-121-vector-retrieval.md) | US-008 | BE | 1 ngày | BE2 | T-116 |
| [T-122 — Kiểm thử truy xuất](T-122-retrieval-tests.md) | US-008 | QA | 1 ngày | BE2 | T-121, T-120 |
| [T-123 — Chỉ báo nguồn tài liệu trên màn hình hỏi đáp](T-123-chat-source-indicator.md) | US-008 | FE | 1 ngày | FE | T-007, T-117 |
| [T-124 — API gỡ tài liệu (Admin)](T-124-delete-document-api.md) | US-010 | BE | 1 ngày | BE2 | T-110, T-005 |
| [T-125 — Nút gỡ tài liệu và hộp thoại xác nhận](T-125-delete-document-ui.md) | US-010 | FE | 0,5 ngày | FE | T-118, T-124 |

## Sprint 2 (23/11 → 04/12/2026) — 24 task · 23,25 ngày

| Task | Story | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-201 — API hội thoại: tạo và đọc tin nhắn](T-201-conversation-api.md) | US-011 | BE | 0,5 ngày | BE2 | T-108 |
| [T-202 — Endpoint SSE gửi câu hỏi](T-202-sse-endpoint.md) | US-011 | BE | 1 ngày | BE2 | T-201 |
| [T-203 — Use case AskQuestion (điều phối hỏi đáp)](T-203-ask-question-usecase.md) | US-011 | BE | 1,5 ngày | BE2 | T-121, T-202, T-205, T-213 |
| [T-204 — System prompt](T-204-system-prompt.md) | US-011 | BE | 0,5 ngày | BE2 | — |
| [T-205 — AnthropicLLMAdapter (streaming + citations)](T-205-anthropic-adapter.md) | US-011 | BE | 2 ngày | BE2 | T-204, T-008 |
| [T-206 — Màn hình hỏi đáp: composer, tin nhắn và lỗi](T-206-chat-ui.md) | US-011 | FE | 2 ngày | FE | T-123, T-207 |
| [T-207 — SSE client trên frontend](T-207-sse-client.md) | US-011 | FE | 1 ngày | FE | T-007 |
| [T-208 — Tinh chỉnh câu trả lời tổng hợp nhiều tài liệu](T-208-multi-doc-tuning.md) | US-012 | BE | 1,5 ngày | BE1 | T-203, T-010 |
| [T-209 — Ánh xạ trích dẫn về tài liệu và trang](T-209-citation-mapping.md) | US-013 | BE | 1,5 ngày | BE1 | T-205 |
| [T-210 — Gắn vị trí trích dẫn vào văn bản trả lời](T-210-citation-markers.md) | US-013 | BE | 1 ngày | BE1 | T-209 |
| [T-211 — Hiển thị trích dẫn và mục Nguồn](T-211-citation-ui.md) | US-013 | FE | 1,5 ngày | FE | T-206, T-210 |
| [T-212 — Đánh giá độ chính xác trích dẫn (KR2.2)](T-212-citation-eval.md) | US-013 | QA | 1 ngày | QA | T-210, T-010 |
| [T-213 — AnswerGuard (logic chống bịa)](T-213-answer-guard.md) | US-014 | BE | 1 ngày | BE1 | — |
| [T-214 — Hiệu chỉnh ngưỡng liên quan τ](T-214-tau-calibration.md) | US-014 | QA | 1 ngày | BE1 | T-203, T-010, T-122 |
| [T-215 — Giao diện "Không tìm thấy thông tin"](T-215-not-found-ui.md) | US-014 | FE | 0,5 ngày | FE | T-206 |
| [T-216 — Kiểm thử prompt injection (thủ công)](T-216-prompt-injection-tests.md) | US-014 | QA | 0,5 ngày | QA | T-203 |
| [T-217 — Tiếng Việt và định dạng ngày giờ](T-217-vietnamese-locale.md) | US-015 | FE | 0,5 ngày | FE | T-007 |
| [T-218 — Hiển thị câu trả lời tăng dần](T-218-streaming-render.md) | US-016 | FE | 1,5 ngày | FE | T-206, T-207 |
| [T-219 — Xử lý mất kết nối khi đang trả lời](T-219-stream-interrupted.md) | US-016 | FE | 0,5 ngày | FE | T-218 |
| [T-220 — Đo độ trễ trên môi trường AWS](T-220-latency-test.md) | US-016 | QA | 1 ngày | QA | T-203, T-006 |
| [T-221 — Cấu hình Nginx và ALB cho SSE](T-221-sse-proxy-config.md) | US-016 | OPS | 0,25 ngày | TL | T-006 |
| [T-222 — Mở PDF tại trang được trích dẫn](T-222-open-citation.md) | US-017 | FE | 0,5 ngày | FE | T-106, T-211 |
| [T-223 — Kiểm tra mở PDF tại trang trên các trình duyệt](T-223-pdf-browser-check.md) | US-017 | QA | 0,5 ngày | QA | T-222 |
| [T-224 — Tải lại hội thoại khi refresh trang](T-224-reload-conversation.md) | US-011 | FE | 0,5 ngày | FE | T-201, T-211 |

## Tuần ổn định (07/12 → 11/12/2026) — 6 task · 8,5 ngày

| Task | Story | Loại | Ước lượng | Phụ trách | Phụ thuộc |
|---|---|---|---|---|---|
| [T-301 — Tinh chỉnh chất lượng câu trả lời](T-301-quality-tuning.md) | — | BE | 3 ngày | BE1 + BE2 + QA | T-208, T-212, T-214 |
| [T-302 — Rà soát bảo mật trước go-live](T-302-security-review.md) | — | OPS | 1,5 ngày | TL | T-224 |
| [T-303 — Khả năng tiếp cận và responsive](T-303-a11y-responsive.md) | — | FE | 1 ngày | FE | T-224 |
| [T-304 — Runbook vận hành](T-304-runbook.md) | — | OPS | 1 ngày | TL | T-006, T-103 |
| [T-305 — UAT với đội BD](T-305-uat.md) | — | QA | 1,5 ngày | PO + QA | T-301, T-302 |
| [T-306 — Go-live](T-306-go-live.md) | — | OPS | 0,5 ngày | TL + PO | T-305, T-304 |

## Chuỗi task quyết định ngày go-live

T-002 → T-004 → T-113 → T-116 → T-121 → T-203 (cần T-205, T-213) → T-209 → T-210 → T-212 / T-214 → T-301 → T-305 → T-306

**Tổng:** 65 task · 68,75 ngày công (ước lượng lý tưởng).
