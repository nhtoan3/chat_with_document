# Kế hoạch kiểm thử tổng thể (Master Test Plan) — "Chat với tài liệu" (MVP v0.4)

> **TP-CWD-001** · v0.2 (`Draft`) · 2026-10-31 · Tuân thủ IEEE 829-2008 (Software Test Documentation)
> **Phạm vi:** MVP v0.4 theo `docs/implement/Implement_plan.md`: **F1 — Xử lý PDF** và **F2 — Hỏi đáp AI**.
> **Tài liệu có hiệu lực khi mâu thuẫn:** `Implement_plan.md` v0.4 và `docs/implement/tasks/` được ưu tiên hơn `User_Stories.md`, `PRD.md` và `SAD.md` (các tài liệu này chưa cập nhật theo v0.4).

**Lịch sử phiên bản**

| Phiên bản | Ngày | Thay đổi | Người soạn |
|---|---|---|---|
| v0.1 | 2026-10-31 | Bản đầu, dựa trên kế hoạch v0.4, 24 task, `traceability.md` ngày 31/10 và mã nguồn hiện tại | Huy Toan (QA / Tech lead) |
| v0.2 | 2026-10-31 | Đồng bộ với mục "Lược bỏ khỏi MVP" của `Implement_plan.md` v0.4: bỏ kiểm thử a11y, quét bảo mật, các mục rà soát bảo mật riêng (injection, phạm vi dữ liệu gửi AI, kiểm tra import), tải đồng thời, exploratory, đo độ phủ; §5 liệt kê đủ phần lược bỏ | Huy Toan (QA / Tech lead) |

**Ký hiệu dùng trong tài liệu**

- **Trạng thái test:** ✅ đã có test tự động và đang pass · 🖐 đã kiểm thủ công, chưa tự động · ⏳ chưa kiểm chứng · 🆕 test case mới do kế hoạch này đề xuất, chưa được viết.
- **Ưu tiên:** **P0** chặn go-live · **P1** cần có, PO được chấp nhận rủi ro · **P2** nên có.
- **Đường dẫn:** `B:` = `backend/tests/`, `F:` = `frontend/src/`.

---

## Mục lục

- [0. Phân tích tài liệu đầu vào](#0-phân-tích-tài-liệu-đầu-vào)
- [1. Định danh kế hoạch kiểm thử](#1-định-danh-kế-hoạch-kiểm-thử-ieee-829-51)
- [2. Giới thiệu](#2-giới-thiệu-ieee-829-52)
- [3. Hạng mục kiểm thử](#3-hạng-mục-kiểm-thử-ieee-829-53)
- [4. Tính năng được kiểm thử](#4-tính-năng-được-kiểm-thử-ieee-829-54)
- [5. Tính năng không kiểm thử](#5-tính-năng-không-kiểm-thử-ieee-829-55)
- [6. Cách tiếp cận](#6-cách-tiếp-cận-ieee-829-56)
- [7. Tiêu chí đạt / không đạt](#7-tiêu-chí-đạt--không-đạt-ieee-829-57)
- [8. Tiêu chí tạm dừng và tiếp tục](#8-tiêu-chí-tạm-dừng-và-tiếp-tục-ieee-829-58)
- [9. Sản phẩm bàn giao của kiểm thử](#9-sản-phẩm-bàn-giao-của-kiểm-thử-ieee-829-59)
- [10. Công việc kiểm thử](#10-công-việc-kiểm-thử-ieee-829-510)
- [11. Nhu cầu môi trường](#11-nhu-cầu-môi-trường-ieee-829-511)
- [12. Trách nhiệm](#12-trách-nhiệm-ieee-829-512)
- [13. Nhân sự và đào tạo](#13-nhân-sự-và-đào-tạo-ieee-829-513)
- [14. Lịch kiểm thử](#14-lịch-kiểm-thử-ieee-829-514)
- [15. Rủi ro và phương án dự phòng](#15-rủi-ro-và-phương-án-dự-phòng-ieee-829-515)
- [16. Phê duyệt](#16-phê-duyệt-ieee-829-516)
- [Phụ lục A. Ma trận truy vết yêu cầu → test case](#phụ-lục-a-ma-trận-truy-vết-yêu-cầu--test-case)
- [Phụ lục B. Đối chiếu checklist IEEE 829](#phụ-lục-b-đối-chiếu-checklist-ieee-829)

---

## 0. Phân tích tài liệu đầu vào

### 0.1 Danh mục tài liệu đầu vào

| Loại | Tài liệu | Phiên bản | Nguồn | Thông tin chính dùng cho kiểm thử |
|---|---|---|---|---|
| Kế hoạch phát triển | `docs/implement/Implement_plan.md` | v0.4 (26/10/2026) | Tech lead / PO | Phạm vi F1 + F2, các phần lược bỏ, 4 đánh đổi, lịch S0 / S1 / ổn định, go-live 30/11/2026, rủi ro |
| Đặc tả task | `docs/implement/tasks/T-001 … T-024` | v0.4 | Tech lead | Đặc tả API, mã lỗi, ca kiểm thử của T-016 và T-022, tiêu chí hoàn thành |
| Ma trận truy vết | `docs/implement/traceability.md` | 31/10/2026 | Tech lead | Yêu cầu → code → test, trạng thái ✅ / 🖐 / ⏳ |
| PRD (≈ SRS) | `docs/requirements/PRD.md` | v0.1 | PO / BA | FR, NFR-001..021, EC-01..14, OKR KR2.1 / KR2.3, launch gate §6.1 |
| User Stories | `docs/requirements/User_Stories.md` | v0.2 (*chưa cập nhật v0.4*) | PO | Tiêu chí chấp nhận AC-US-005..015 (chỉ dùng phần còn trong phạm vi) |
| SAD (IEEE 1016-2009) | `docs/design/SAD.md` | v0.2 | Kiến trúc sư | Mục "Phạm vi kiến trúc cho MVP", ADR-006 / 010, port `LLMPort` / `EmbeddingPort` / `ObjectStoragePort` |
| Lược đồ dữ liệu | `docs/design/schema.sql`, `backend/app/migrations/` | `0001_init` | BE | Bảng `documents`, `ingestion_jobs`, `chunks`, `qa_log` |
| Thiết kế UI / UX | `docs/design/html_design/03-documents.html`, `04-chat.html`, `08-errors.html` | v0.1 | Thiết kế | Bố cục màn hình Tài liệu và Hỏi đáp (bản tối giản theo T-015, T-021) |
| Hợp đồng API | `backend/app/api/routers/*.py`, `platform/errors.py` | mã hiện tại | BE | 3 endpoint `/api/v1`, 11 mã lỗi problem+json |
| Biên bản UAT | `docs/implement/evidence/UAT.md` | mẫu | QA / PO | 5 kịch bản UAT |
| Golden set | `backend/tests/eval/golden.yaml` | mẫu (4 positive, 2 negative) | BD / QA | Bộ câu hỏi chuẩn; BD bàn giao ≥ 30 positive + ≥ 10 negative |

### 0.2 Yêu cầu kiểm thử được (trích từ PRD, task và ma trận truy vết)

Kế hoạch dùng lại **mã yêu cầu gốc** của dự án để truy vết thống nhất với `traceability.md`.

| Mã yêu cầu | Loại | Mô tả (bản MVP) | Ưu tiên | Nguồn |
|---|---|---|---|---|
| US-005 / BR-001 | Chức năng | Tải lên 1–10 PDF mỗi lần, mỗi tệp ≤ 20 MB | P0 | T-009, T-015 |
| AC-US-005-5 | Chức năng | Một tệp lỗi không chặn các tệp hợp lệ trong cùng lô | P0 | T-009 |
| NFR-006 / EC-14 | Quy tắc nghiệp vụ | Bộ tài liệu tối đa 50 tài liệu → `collection_full` | P1 | T-009 |
| EC-08 (rút gọn) | Quy tắc nghiệp vụ | Trùng tên tệp → `duplicate_name` (không có hộp thoại thay thế) | P1 | T-009 |
| US-007 / FR-007 / BR-005 | Chức năng | Báo tên tệp và lý do lỗi: `not_pdf`, `file_too_large`, `encrypted_pdf`, `no_text_layer`, `too_many_pages`, `corrupted`, `transient_exhausted` | P0 | T-009, T-011, T-015 |
| US-006 / FR-006 | Chức năng | Danh sách tài liệu, trạng thái tự cập nhật mỗi 3 s, toast khi Sẵn sàng | P0 | T-014, T-015 |
| NFR-003 | Hiệu năng | PDF văn bản 50 trang chuyển Sẵn sàng ≤ 60 s | P1 | T-013 |
| ADR-006 | Thiết kế | Chunk theo trang, ~500 token, có chồng lấp, không vượt 2 trang thường | P0 | T-012 |
| ADR-010 | Thiết kế | Hàng đợi PostgreSQL: hai worker không lấy trùng việc, thu hồi việc treo | P0 | T-010 |
| NFR-021 | Độ tin cậy | Lỗi tạm thời thử lại 3 lần (10 / 40 / 160 s) rồi `transient_exhausted`; tệp lỗi không ảnh hưởng tài liệu khác | P0 | T-010, T-013 |
| REQ-VN-01 | Chức năng | Văn bản tiếng Việt giữ đúng dấu (chuẩn hóa NFC) | P0 | T-011 |
| REQ-FN-01 | Bảo mật | Chuẩn hóa tên tệp: bỏ đường dẫn, NFC, ≤ 255 ký tự | P1 | T-009 |
| US-008 / BR-002 | Chức năng | Chỉ dùng tài liệu `ready` làm nguồn trả lời | P0 | T-017 |
| AC-US-008-4 / EC-01 | Chức năng | Chưa có tài liệu Sẵn sàng → khóa ô hỏi / 409 `no_documents` | P0 | T-020, T-021 |
| US-011 / BR-006 | Chức năng | Hỏi bằng ngôn ngữ tự nhiên, nhận câu trả lời Markdown | P0 | T-019, T-020, T-021 |
| AC-US-011-3, 4 / EC-12 | Chức năng | Câu hỏi sau khi trim dài 1–2000 ký tự; rỗng thì khóa nút Gửi | P0 | T-020, T-021 |
| AC-US-011-8 / EC-06 | Chức năng | AI hoặc TEI lỗi → 503 `ai_unavailable`, thông điệp "Hệ thống đang bận…", nút Hỏi lại | P0 | T-019, T-020, T-021 |
| NFR-020 | Độ tin cậy | AI không phản hồi → báo lỗi trong ≤ 30 s, giao diện không treo (cách đo cho AC-US-011-8) | P1 | PRD §7.4, T-021 |
| BRU-001 / US-014 (rút gọn) | Quy tắc nghiệp vụ | Chỉ trả lời từ tài liệu; không có thông tin → "Không tìm thấy thông tin…" (**chỉ bằng prompt**) | P0 | T-018, T-019 |
| US-015 | Chức năng | Câu trả lời và giao diện bằng tiếng Việt | P0 | T-007, T-018 |
| UXC-09 | Bảo mật | Câu trả lời render an toàn qua `marked` + `DOMPurify` (chống XSS) | P0 | T-021 |
| PRD §6.2 / CN-06 | Bảo mật / dữ liệu | `qa_log` chỉ lưu số liệu; log không chứa nội dung câu hỏi, câu trả lời, tài liệu | P0 | T-004, T-005, T-020 |
| KR2.1 | Chất lượng | ≥ 80% câu positive của golden set được chấm đúng | P0 | T-008, T-023 |
| KR2.3 | Chất lượng | ≥ 90% câu negative nhận "không tìm thấy" | P0 | T-008, T-023 |
| NFR-001 | Hiệu năng | p90 thời gian trả lời ≤ 15 s (MVP chấp nhận 10–20 s, không streaming) | P1 | T-020, T-023 |
| API-CONTRACT | Giao diện | Lỗi API luôn là problem+json có `code` thuộc `ERRORS`; có thông điệp trong `vi.json` | P0 | T-005, T-007 |
| NFR-010 | Bảo mật | HTTPS, TLS ≥ 1.2, 80 → 443 | P0 | T-006 |
| NFR-011 | Bảo mật | S3 SSE-KMS + Block Public Access; RDS mã hóa KMS | P0 | T-006 |
| SEC-NET (thay đăng nhập) | Bảo mật | Chỉ truy cập được từ dải IP / VPN công ty; không mở `0.0.0.0/0` | P0 | T-006 |
| OPS-LOCAL | Vận hành | `make dev` dựng đủ stack healthy | P1 | T-002 |
| OPS-CI | Vận hành | CI chạy lint + test mỗi PR; lỗi lint chặn merge | P0 | T-003 |
| OPS-DEPLOY | Vận hành | `deploy.sh` kiểm tra `/healthz`; `rollback.sh` quay về tag trước < 10 phút | P0 | T-006 |

### 0.3 Thành phần thiết kế cần kiểm thử (SAD — phạm vi MVP)

| Viewpoint | Thành phần | Loại | Giao diện | Máy trạng thái | Phụ thuộc |
|---|---|---|---|---|---|
| Composition | `modules/documents` | Module (hexagonal) | Use case `upload`, repository, `job_queue` | — | `platform/storage.py`, PostgreSQL |
| Composition | `modules/qa` | Module (hexagonal) | `ports.py`: `LLMPort`, `EmbeddingPort`, `RetrievalPort` | — | TEI, Anthropic API |
| Composition | `platform/` | Kernel | config, DB, `errors.py`, logging JSON, storage S3 | — | — |
| Component & Connector | `api` (FastAPI) | Service | REST `/api/v1/*`, `/healthz` | — | PostgreSQL, S3, TEI, Claude |
| Component & Connector | `worker` (×2) | Tiến trình nền | Poll `ingestion_jobs` mỗi 2 s bằng `FOR UPDATE SKIP LOCKED` | Trạng thái job | PostgreSQL, S3, TEI |
| Component & Connector | `tei` (`bge-m3`) | Dịch vụ embedding | HTTP | — | — |
| Component & Connector | `web` (React + Nginx) | SPA | Gọi `/api/v1`, `client_max_body_size 210m`, `proxy_read_timeout 90s` | — | `api` |
| Interaction | Luồng ingestion | Tuần tự | upload → S3 → job → extract → chunk → embed → ghi `chunks` | `queued → processing → ready \| failed` | — |
| Interaction | Luồng hỏi đáp | Tuần tự | validate → kiểm tra có `ready` → embed câu hỏi → top-N vector → Claude → `qa_log` | — | — |
| Information | `documents`, `ingestion_jobs`, `chunks` (pgvector HNSW), `qa_log` | Lược đồ | Migration `0001_init` | — | PostgreSQL 16 + `vector` |
| State Dynamics | Tài liệu | Máy trạng thái | Sự kiện: tải lên, worker nhận, thành công, lỗi vĩnh viễn, hết lượt retry | `queued → processing → ready`; `processing → failed(error_code)`; `processing (treo) → queued` khi thu hồi | `job_queue.py` |

### 0.4 Thành phần UI / UX

| Thành phần | Màn hình | Tương tác | Trạng thái | Khả năng tiếp cận | Luồng |
|---|---|---|---|---|---|
| Nút "Chọn file PDF" (`accept=".pdf" multiple`) | Tài liệu (`/documents`) | Chọn nhiều tệp | Bình thường, "Đang tải lên…" | Badge có icon **và** chữ | Chọn → kiểm tra client → gửi |
| Banner lỗi lô | Tài liệu | — | > 10 tệp | Chữ, không chỉ màu | — |
| Bảng tài liệu | Tài liệu | Tự làm mới 3 s khi `counts.processing > 0` | Đang chờ / Đang xử lý / Sẵn sàng / Lỗi + lý do | Badge icon + chữ | — |
| Toast "[tên] đã sẵn sàng" | Tài liệu | — | Hiện khi chuyển `ready` | — | — |
| Số trên sidebar | Shell | — | = `counts.ready` | — | — |
| Ô nhập câu hỏi (`textarea`) | Hỏi đáp (`/ask`) | Enter gửi, Shift+Enter xuống dòng; bộ đếm `n/2000` | Khóa khi rỗng, > 2000 ký tự hoặc chưa có tài liệu Sẵn sàng | Dùng được bằng bàn phím | Nhập → gửi |
| Bong bóng câu trả lời | Hỏi đáp | — | "Đang tìm câu trả lời…" + "Có thể mất tới 20 giây"; Markdown đã làm sạch; nhãn "Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc" | — | — |
| Trạng thái lỗi | Hỏi đáp | Nút **Hỏi lại** | 503 / mất mạng → "Hệ thống đang bận, vui lòng thử lại" | — | Lỗi → Hỏi lại |
| Trạng thái trống | Hỏi đáp | Link `/documents` | "Tải lên tài liệu để bắt đầu" | — | EC-01 |

### 0.5 Thành phần API

Không có xác thực (MVP); bảo vệ ở tầng mạng (ALB). Mọi lỗi là `application/problem+json` có trường `code`.

| Endpoint | Method | Request | Response thành công | Mã lỗi có thể có |
|---|---|---|---|---|
| `/api/v1/documents` | POST | `multipart/form-data`, trường `files` (1–10 tệp) | 202 `{items:[{filename, document_id, status:"queued"} \| {filename, error_code}]}` | 422 `too_many_files`, 409 `collection_full`, 502 `storage_error`, 500 `internal_error`; theo từng tệp: `not_pdf`, `file_too_large`, `duplicate_name` |
| `/api/v1/documents` | GET | — | 200 `{items:[{id, filename, pages, uploaded_at, status, error_code}], counts:{ready, processing, failed, total}, limit:50}`, sắp xếp `uploaded_at DESC` | 500 `internal_error` |
| `/api/v1/ask` | POST | JSON `{question: str}` | 200 `{answer: markdown, latency_ms}` | 422 `question_invalid`, 409 `no_documents`, 503 `ai_unavailable`, 500 `internal_error` |
| `/healthz` | GET | — | 200 | — |

### 0.6 User story trong phạm vi và tiêu chí chấp nhận (bản MVP)

| Story | Mô tả | Tiêu chí chấp nhận áp dụng cho MVP | Ưu tiên | Phụ thuộc |
|---|---|---|---|---|
| US-005 | Là Chuyên viên BD, tôi muốn tải lên PDF của dự án | 1–10 tệp, ≤ 20 MB; tệp lỗi không chặn tệp hợp lệ; tối đa 50 tài liệu | P0 | T-005 |
| US-006 | Tôi muốn biết tài liệu nào đang xử lý / đã sẵn sàng | Trạng thái tự cập nhật không cần tải lại trang; toast khi Sẵn sàng; PDF 50 trang ≤ 60 s | P0 | US-005 |
| US-007 | Tôi muốn được báo rõ khi tệp không xử lý được | Mỗi mã lỗi có thông điệp tiếng Việt riêng | P0 | US-005 |
| US-008 | Câu trả lời chỉ dựa trên tài liệu Sẵn sàng | Tài liệu đang xử lý không được dùng; chưa có tài liệu → khóa ô hỏi | P0 | US-006 |
| US-011 | Tôi muốn hỏi bằng ngôn ngữ tự nhiên | 1–2000 ký tự; lỗi AI → Hỏi lại; ≥ 80% đúng trên golden set | P0 | US-008 |
| US-014 (rút gọn) | Hệ thống nói rõ khi không có thông tin | ≥ 90% câu negative nhận "không tìm thấy" (chỉ dựa vào prompt) | P0 | US-011 |
| US-015 | Dùng tiếng Việt | Giao diện từ `vi.json`; câu trả lời tiếng Việt | P0 | — |

### 0.7 Đánh giá rủi ro sản phẩm (đầu vào cho ưu tiên kiểm thử)

Điểm rủi ro = Khả năng (1–5) × Ảnh hưởng (1–5). Điểm ưu tiên (thang 100) = điểm rủi ro × 4.

| Mã | Rủi ro sản phẩm | Khả năng | Ảnh hưởng | Điểm | Chiến lược kiểm thử |
|---|---|---|---|---|---|
| PR-01 | AI bịa thông tin; không có trích dẫn nên người dùng không kiểm chứng được (RSK-001) | 4 | 5 | **20** | Golden set positive + negative, chấm hằng ngày (T-023); UAT câu ngoài tài liệu; kiểm tra nhãn cảnh báo AI |
| PR-02 | Truy cập trái phép vì không có đăng nhập | 3 | 5 | **15** | SEC-001: kiểm tra từ mạng ngoài; rà soát security group trước go-live và sau mỗi thay đổi hạ tầng |
| PR-03 | Truy xuất sai đoạn hoặc dùng tài liệu chưa Sẵn sàng | 3 | 4 | **12** | Integration với pgvector thật; kiểm tra thủ công với `bge-m3` thật |
| PR-04 | Lộ nội dung tài liệu qua log hoặc `qa_log` | 2 | 5 | **10** | Kiểm tra tập cột `qa_log`; rà soát log CloudWatch sau UAT |
| PR-05 | XSS qua câu trả lời Markdown | 2 | 5 | **10** | Unit `markdown.test.ts`; E2E với payload độc hại |
| PR-06 | Ingestion treo hoặc hai worker xử lý trùng một tài liệu | 2 | 4 | **8** | Integration hàng đợi; thử kill worker khi đang xử lý |
| PR-07 | Thời gian trả lời quá dài khiến người dùng bỏ dùng | 3 | 3 | **9** | Đo p90 qua `make eval` và `qa_log` |
| PR-08 | Lỗi AI không được báo kịp (timeout 60 s × tối đa 3 lần gọi > ngưỡng 30 s của NFR-020) | 4 | 3 | **12** | PERF-004: giả lập Claude treo; đo thời gian đến khi hiện thông báo lỗi |
| PR-09 | Thông điệp lỗi thiếu hoặc lệch giữa backend và `vi.json` | 2 | 3 | **6** | Unit kiểm tra mọi khóa trong `ERRORS` đều có trong `vi.json` (🆕) |

---

## 1. Định danh kế hoạch kiểm thử (IEEE 829 §5.1)

| Thuộc tính | Giá trị |
|---|---|
| **Mã tài liệu** | TP-CWD-001 |
| **Tên** | Kế hoạch kiểm thử tổng thể (MTP) — Chat với tài liệu, MVP v0.4 |
| **Phiên bản** | v0.2 |
| **Ngày phát hành** | 2026-10-31 |
| **Trạng thái** | Draft, chờ review |
| **Phân loại** | Nội bộ |
| **Người soạn** | Huy Toan (QA / Tech lead) |
| **Người phê duyệt** | PO, Tech lead, Quản lý (xem §16) |
| **Đường dẫn** | `docs/07-verification/Test_Plan.md` |
| **Tài liệu liên quan** | IMP-CWD-001 v0.4, PRD-CWD-001 v0.1, SAD v0.2, `traceability.md` |

---

## 2. Giới thiệu (IEEE 829 §5.2)

### 2.1 Mục đích

Kế hoạch này:

- xác định chiến lược kiểm thử cho MVP "Chat với tài liệu" trong phạm vi v0.4;
- liệt kê các mức và loại kiểm thử, kèm tiêu chí vào / ra cho từng mức;
- phân công vai trò, lịch và môi trường kiểm thử;
- định nghĩa tiêu chí đạt / không đạt làm căn cứ cho buổi họp go / no-go ngày 27/11/2026;
- truy vết từng yêu cầu trong phạm vi tới test case (Phụ lục A).

### 2.2 Tóm tắt hệ thống

Ứng dụng web nội bộ cho đội BD. Người dùng tải PDF dự án lên. Worker trích văn bản, chia đoạn theo trang và tạo embedding (TEI `bge-m3`) lưu trong PostgreSQL + pgvector. Khi người dùng hỏi bằng tiếng Việt, hệ thống truy xuất top-N đoạn liên quan (`QA_TOP_N = 12`) và gọi Claude (`claude-opus-5-5`) để trả lời **chỉ dựa trên tài liệu**. Hệ thống không có đăng nhập; truy cập được giới hạn theo IP / VPN tại ALB. Môi trường vận hành là một EC2 chạy Docker Compose, cùng RDS và S3 trên AWS.

### 2.3 Phạm vi kiểm thử

**Trong phạm vi:**

- Kiểm thử chức năng F1 (tải lên, ingestion, danh sách, trạng thái, thông báo lỗi) và F2 (hỏi đáp, kiểm tra đầu vào, xử lý lỗi, render an toàn).
- Kiểm thử API cho 3 endpoint `/api/v1` và hợp đồng lỗi problem+json.
- Kiểm thử tích hợp với PostgreSQL + pgvector thật (Testcontainers) và S3Mock; LLM giả lập (`FakeLLM`).
- Đánh giá chất lượng câu trả lời bằng golden set với Claude thật (KR2.1, KR2.3).
- Kiểm thử hiệu năng mức MVP: NFR-001, NFR-003, NFR-020 và giới hạn RAM khi tải lên (T-009).
- Kiểm tra bảo mật **chỉ theo tiêu chí hoàn thành của task** (T-006, T-009, T-021) và quy tắc CN-06: giới hạn mạng, TLS, mã hóa at-rest, XSS, an toàn tải tệp, không log nội dung. Không có rà soát bảo mật riêng.
- Kiểm thử giao diện (E2E) cho luồng chính trên Chrome.
- Kiểm thử vận hành: CI, migration, deploy, rollback, smoke sau deploy.
- Kiểm thử hồi quy tự động trong CI và UAT với đại diện BD.

**Ngoài phạm vi:** xem §5.

### 2.4 Mục tiêu kiểm thử

| Mã | Mục tiêu | Tiêu chí thành công | Truy vết |
|---|---|---|---|
| OBJ-001 | Xác nhận mọi yêu cầu chức năng P0 của F1 và F2 | 100% yêu cầu P0 có ít nhất 1 test case đạt | Mục 0.2 |
| OBJ-002 | Xác nhận hợp đồng API | 100% endpoint và 100% mã lỗi trong `ERRORS` được ít nhất 1 test kiểm tra | Mục 0.5 |
| OBJ-003 | Xác nhận chất lượng câu trả lời | KR2.1 ≥ 80%, KR2.3 ≥ 90% trên golden set do BD bàn giao | KR2.1, KR2.3 |
| OBJ-004 | Xác nhận hiệu năng mức MVP | NFR-001 p90 ≤ 15 s; NFR-003 ≤ 60 s; NFR-020 ≤ 30 s | NFR-001, 003, 020 |
| OBJ-005 | Xác nhận bảo mật mức MVP | 0 lỗi bảo mật mức Blocker / Critical; không truy cập được từ mạng ngoài | NFR-010, 011, SEC-NET, UXC-09, CN-06 |
| OBJ-006 | Xác nhận giao diện tiếng Việt và luồng UI | Các kịch bản E2E-001..008 đạt trên Chrome | US-015, T-015, T-021 |
| OBJ-007 | Xác nhận khả năng vận hành | CI xanh; deploy và rollback < 10 phút; smoke sau deploy đạt | OPS-CI, OPS-DEPLOY |
| OBJ-008 | Người dùng chấp nhận | Biên bản UAT được ký: ≥ 8/10 câu dùng được, 3/3 câu ngoài tài liệu nhận "không tìm thấy" | T-024 |

### 2.5 Tài liệu tham chiếu

| Tài liệu | Phiên bản | Nguồn |
|---|---|---|
| `docs/implement/Implement_plan.md` | v0.4 | Tech lead / PO |
| `docs/implement/tasks/README.md`, T-001..T-024 | v0.4 | Tech lead |
| `docs/implement/traceability.md` | 31/10/2026 | Tech lead |
| `docs/requirements/PRD.md` | v0.1 | PO / BA |
| `docs/requirements/User_Stories.md` | v0.2 | PO |
| `docs/requirements/BRD.md` | v0.1 | BA |
| `docs/design/SAD.md` (IEEE 1016-2009) | v0.2 | Kiến trúc sư |
| `docs/design/html_design/*.html` | v0.1 | Thiết kế |
| `docs/implement/evidence/UAT.md` | mẫu | QA |
| `AGENTS.md` | — | Tech lead |
| IEEE 829-2008 Standard for Software and System Test Documentation | 2008 | IEEE |

---

## 3. Hạng mục kiểm thử (IEEE 829 §5.3)

### 3.1 Phần mềm được kiểm thử

Phiên bản được kiểm thử xác định bằng tag image `sha-<short>` do CI build trên `main`. Tag đưa vào UAT phải là tag được deploy lúc go-live.

| Mã | Hạng mục | Vị trí | Công nghệ | Hình thức kiểm thử |
|---|---|---|---|---|
| SI-001 | API service | `backend/app/api/`, `backend/app/modules/` | Python 3.12, FastAPI | Unit, integration, API, E2E |
| SI-002 | Worker ingestion | `backend/app/worker/`, `modules/documents/` | Python, PostgreSQL queue | Unit, integration |
| SI-003 | Adapter AI (Claude) | `modules/qa/adapters/anthropic_llm.py` | SDK `anthropic` | Unit (client giả lập), live (thủ công), eval |
| SI-004 | Adapter embedding và truy xuất | `qa/adapters/tei_embedding.py`, `pg_retrieval.py` | TEI `bge-m3`, pgvector | Integration, thủ công |
| SI-005 | System prompt | `modules/qa/prompts.py` | — | Unit (quy tắc bắt buộc), golden eval |
| SI-006 | Ứng dụng web | `frontend/src/` | React, TypeScript, Vite | Unit (vitest), E2E (Playwright) |
| SI-007 | Lược đồ CSDL | `backend/app/migrations/` (`0001_init`) | Alembic, PostgreSQL 16 + `vector` | Integration (Testcontainers), deploy |
| SI-008 | Cấu hình và hạ tầng | `docker-compose.yml`, `infra/*`, `frontend/nginx.conf`, `.github/workflows/ci.yml` | Docker Compose, Nginx, AWS | Vận hành, bảo mật |
| SI-009 | Tài liệu cho người dùng | `docs/implement/Huong_dan_su_dung.md` | Markdown | Review trong UAT |

### 3.2 Tài sản kiểm thử

| Mã | Tài sản | Định dạng | Vị trí | Phụ trách |
|---|---|---|---|---|
| TA-001 | Test tự động backend | pytest | `B:unit/`, `B:integration/` | BE1, BE2 |
| TA-002 | Test tự động frontend | vitest | `F:**/*.test.ts` | FE |
| TA-003 | Test E2E (🆕) | Playwright, TypeScript | đề xuất `frontend/e2e/` | FE + QA |
| TA-004 | PDF fixture giả lập | PDF, script `make_pdfs.py` | `B:fixtures/pdfs/` (`sample/`, `encrypted.pdf`, `scanned.pdf`, `corrupted.pdf`, `fake.pdf`; `301_pages.pdf` sinh khi chạy test) | BE1 |
| TA-005 | Fake port | Python | `B:fakes/fakes.py` (`FakeLLM`, …) | BE2 |
| TA-006 | Golden set và script đánh giá | YAML, CSV | `B:eval/golden.yaml`, `run_eval.py`, `score.py`, `results/*.csv` | BD + QA |
| TA-007 | Môi trường container | Docker Compose, Testcontainers | `docker-compose.yml`, `B:integration/conftest.py` | TL |
| TA-008 | Biên bản UAT | Markdown | `docs/implement/evidence/UAT.md` | QA / PO |

> **Quy tắc dữ liệu:** fixture chỉ là dữ liệu giả lập. Không commit PDF thật của khách hàng. Nếu OQ-008 cho phép dùng tài liệu thật, chỉ dùng chúng trên môi trường AWS trong UAT.

---

## 4. Tính năng được kiểm thử (IEEE 829 §5.4)

### 4.1 Ma trận ưu tiên

| Ưu tiên | Tính năng / thành phần | Story | Yêu cầu | Điểm rủi ro (/100) |
|---|---|---|---|---|
| **P0** | F2 — Chất lượng câu trả lời, chống bịa | US-011, US-014 | KR2.1, KR2.3, BRU-001 | 80 |
| **P0** | Giới hạn truy cập mạng (thay đăng nhập) | — | SEC-NET, NFR-010 | 60 |
| **P0** | F2 — Truy xuất chỉ từ tài liệu Sẵn sàng | US-008 | BR-002 | 48 |
| **P0** | F2 — Báo lỗi AI kịp thời, Hỏi lại | US-011 | AC-US-011-8, NFR-020 | 48 |
| **P0** | F2 — Render an toàn (XSS) | US-011 | UXC-09 | 40 |
| **P0** | Không log nội dung | — | CN-06, PRD §6.2 | 40 |
| **P0** | F1 — Tải lên và kiểm tra tệp | US-005, US-007 | BR-001, FR-007, AC-US-005-5 | 36 |
| **P0** | F1 — Ingestion, hàng đợi, retry | US-006 | ADR-006, ADR-010, NFR-021 | 32 |
| **P1** | Hiệu năng trả lời và ingestion | US-006, US-011 | NFR-001, NFR-003 | 36 |
| **P1** | F1 — Danh sách và trạng thái tự cập nhật | US-006 | FR-006 | 24 |
| **P1** | Giới hạn 50 tài liệu, trùng tên | US-005 | NFR-006, EC-08 | 16 |
| **P1** | Vận hành: CI, deploy, rollback | — | OPS-CI, OPS-DEPLOY | 24 |

### 4.2 Ma trận tính năng × loại kiểm thử

| Tính năng | Unit | Integration | API | E2E / hệ thống | UAT | Hồi quy | Hiệu năng | Bảo mật | Eval AI |
|---|---|---|---|---|---|---|---|---|---|
| F1.1 Tải lên + kiểm tra tệp | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (RAM) | ✓ | — |
| F1.2 Ingestion (trích, chunk, embed) | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ (NFR-003) | — | — |
| F1.3 Hàng đợi, retry | ✓ | ✓ | — | — | — | ✓ | — | — | — |
| F1.4 Danh sách, trạng thái, toast | — | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — |
| F2.1 Kiểm tra câu hỏi | ✓ | ✓ | ✓ | ✓ | — | ✓ | — | — | — |
| F2.2 Truy xuất vector | — | ✓ | — | — | ✓ | ✓ | ✓ | — | ✓ |
| F2.3 Gọi Claude, prompt | ✓ | ✓ (Fake) | ✓ | ✓ | ✓ | ✓ | ✓ (NFR-001) | — | ✓ |
| F2.4 Xử lý lỗi AI | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ (NFR-020) | — | — |
| F2.5 Render câu trả lời | ✓ | — | — | ✓ | ✓ | ✓ | — | ✓ (XSS) | — |
| Nền tảng: lỗi, log, `qa_log` | ✓ | ✓ | ✓ | — | — | ✓ | — | ✓ | — |
| Hạ tầng AWS | — | — | — | ✓ (smoke) | ✓ | — | — | ✓ | — |

### 4.3 Mô tả chi tiết tính năng

| Mã | Tính năng | Mô tả | Phần kiểm thử được | Tiêu chí chấp nhận |
|---|---|---|---|---|
| F1.1 | Tải lên PDF | `POST /documents`, kiểm tra cả lô và từng tệp, đọc stream, lưu S3, xếp hàng trong một transaction | Số tệp, magic bytes `%PDF-`, kích thước, trùng tên, giới hạn 50, chuẩn hóa tên | Mã lỗi đúng theo bảng T-009; tệp lỗi không chặn tệp hợp lệ; tải 10 × 20 MB không làm RAM `api` tăng quá 100 MB |
| F1.2 | Ingestion | Worker trích văn bản (NFC), phát hiện mã hóa / không có lớp văn bản / > 300 trang / hỏng; chunk theo trang; embed; ghi `chunks` | Từng mã lỗi; chunk ≤ giới hạn, có chồng lấp; tiếng Việt đúng dấu | Tài liệu hợp lệ → `ready` có chunk; tài liệu lỗi → `failed` kèm mã |
| F1.3 | Hàng đợi | `SELECT … FOR UPDATE SKIP LOCKED`, thu hồi job treo, backoff 10 / 40 / 160 s | Đồng thời 2 worker; job treo; lỗi tạm thời | Không lấy trùng; job treo được xử lý lại; hết retry → `transient_exhausted` |
| F1.4 | Danh sách tài liệu | `GET /documents` + UI bảng, badge, toast, poll 3 s | `counts`, thứ tự, định dạng ngày `dd/mm/yyyy`, toast | Chuyển Đang chờ → Sẵn sàng không cần tải lại trang |
| F2.1 | Kiểm tra câu hỏi | Trim; 1–2000 ký tự; client và server | Rỗng, chỉ khoảng trắng, 2000, 2001 ký tự | 422 `question_invalid`; nút Gửi bị khóa ở client |
| F2.2 | Truy xuất | Embed câu hỏi, top-N trên chunk của tài liệu `ready` | Xếp hạng đúng; bỏ tài liệu chưa Sẵn sàng | Ngữ cảnh gửi LLM chỉ gồm chunk của tài liệu `ready` |
| F2.3 | Trả lời | Prompt + chunk → Claude; refusal → câu "không tìm thấy"; `qa_log` chỉ số liệu | Định dạng ngữ cảnh, quy tắc prompt, thinking bị bỏ, ghép text block | 200 `{answer, latency_ms}`; golden set đạt ngưỡng |
| F2.4 | Lỗi AI | Lỗi TEI / LLM → `qa_log(status='error')` → 503 | Timeout, lỗi mạng, thiếu khóa API | 503 `ai_unavailable`; UI hiện Hỏi lại; báo lỗi trong ≤ 30 s |
| F2.5 | Render | `marked` + `DOMPurify` trong `features/ask/markdown.ts` | Danh sách, in đậm, `<script>`, `<img onerror>`, link `javascript:` | Không thực thi script; định dạng Markdown hợp lệ vẫn hiển thị |

---

## 5. Tính năng không kiểm thử (IEEE 829 §5.5)

### 5.1 Lược bỏ theo `Implement_plan.md` v0.4 §1

Các phần dưới đây không được xây dựng trong MVP, nên kế hoạch này không có test case nào cho chúng.

| Phần lược bỏ | Story / mục gốc | Thay thế trong MVP | Rủi ro còn lại |
|---|---|---|---|
| Đăng nhập / đăng xuất, phân quyền, hội thoại riêng tư | US-001, 002, 003, 023 (và US-004); EC-11 | Giới hạn truy cập theo IP / VPN công ty, kiểm bằng SEC-001 | Cao (đánh đổi #2). Nếu IT không cấp được dải IP thì bắt buộc thêm ALB OIDC / Basic Auth và bổ sung test xác thực (Implement_plan §4) |
| Trích dẫn tài liệu + trang, mở PDF tại trang | US-013, 017; KR2.2; EC-10 | Nhãn "Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc" | Cao (đánh đổi #1, PR-01) |
| Kiểm tra "không tìm thấy" phía server (AnswerGuard, ngưỡng τ) | US-014 bản đầy đủ | Chỉ dựa vào prompt, đo bằng EVAL-002 | Trung bình (đánh đổi #3) |
| Câu trả lời hiện dần (streaming), nút Dừng | US-016, 025; EC-04 | Spinner, chờ 10–20 s | Thấp |
| Gỡ tài liệu trên giao diện | US-010 | Tech lead xóa trực tiếp trong DB / S3 | Trung bình (đánh đổi #4) |
| Tinh chỉnh đa nguồn riêng | US-012 | Truy xuất top-N chung trên mọi tài liệu Sẵn sàng | Thấp |
| PoC | — | — | — |
| Rà soát bảo mật riêng | — | Chỉ kiểm các tiêu chí bảo mật đã có trong task (§6.3.8) | Trung bình |
| Kiểm thử a11y | — | Không có | Thấp (20 người dùng nội bộ) |
| Runbook đầy đủ | — | Lệnh deploy / rollback và truy vấn số liệu trong README (OPS-005, 006, 009) | Thấp |
| Quét bảo mật trong CI (`pip-audit`, gitleaks, Semgrep) | T-003 | CI chỉ chạy lint + test | Trung bình |

### 5.2 Các phần khác không kiểm thử

| Tính năng | Lý do | Rủi ro |
|---|---|---|
| Đánh giá câu trả lời, lịch sử hội thoại, số liệu trong app (US-018..022); EC-02 | Đã lược bỏ (`traceability.md` §5) | Thấp |
| Hộp thoại trùng tên "Thay thế / Giữ cả hai" (EC-08 đầy đủ, EC-13) | Bản rút gọn của T-009 chỉ trả `duplicate_name` | Thấp |
| Kéo-thả, thanh tiến trình từng tệp, thử lại khi mất mạng lúc tải (EC-03, EC-05) | Ngoài phạm vi T-015 | Thấp |
| Tải đồng thời nhiều người (NFR-008), stress, endurance, spike | Không có trong kế hoạch v0.4; 20 người dùng nội bộ | Thấp; theo dõi p90 trong `qa_log` khi pilot |
| Thời gian hoạt động của Anthropic API và AWS | Trách nhiệm nhà cung cấp | Trung bình |
| Trình duyệt khác Chrome, giao diện di động | Đội BD dùng Chrome trên máy tính | Thấp |
| Trích văn bản từ PDF scan (OCR) | Ngoài phạm vi; hệ thống phải báo `no_text_layer` | Thấp |

---

## 6. Cách tiếp cận (IEEE 829 §5.6)

### 6.1 Chiến lược chung

- **Theo rủi ro:** thứ tự ưu tiên ở §4.1. Rủi ro cao nhất (chất lượng AI, truy cập trái phép) được kiểm bằng phép đo thật (golden set, thử từ mạng ngoài), không chỉ bằng test giả lập.
- **Kim tự tháp kiểm thử:** phần lớn là unit và integration chạy trong CI. Chỉ vài kịch bản E2E cho luồng chính. Phần phụ thuộc AI và hạ tầng thật được kiểm thủ công hoặc bán tự động (eval, live, UAT).
- **Ranh giới giả lập:** use case chỉ phụ thuộc port, nên unit test dùng fake port. Integration dùng PostgreSQL + pgvector thật (Testcontainers) và S3Mock, với `FakeLLM` thay Claude. Claude thật chỉ dùng ở marker `live`, `make eval` và UAT.
- **Shift-left:** mỗi task có tiêu chí "CI xanh". Commit chỉ được merge khi `make lint` và `make test` xanh.
- **Truy vết:** mỗi test case có mã và trỏ tới yêu cầu (Phụ lục A). Khi thêm hoặc đổi test thì cập nhật `docs/implement/traceability.md`.

### 6.2 Tự động và thủ công

| Hạng mục | Tự động (CI mỗi PR) | Bán tự động (chạy bằng lệnh, người chấm) | Thủ công |
|---|---|---|---|
| Unit backend (22 hàm test, một số có tham số) + frontend (15 test) | ✓ | | |
| Integration backend (14 hàm test, Testcontainers) | ✓ | | |
| E2E Playwright (🆕, API thật trên stack local) | ✓ (job riêng, có thể chạy hằng đêm do TEI chậm) | | |
| Test `live` gọi Claude thật | | ✓ `pytest -m live` | |
| Golden eval | | ✓ `make eval` + chấm cột `correct` + `make eval-score` | |
| Đo hiệu năng | | ✓ eval (latency), script đo ingestion | |
| Kiểm tra mạng, TLS, KMS | | | ✓ |
| UAT | | | ✓ |

### 6.3 Các mức và loại kiểm thử

#### 6.3.1 Unit test

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | Developer của task (BE1, BE2, FE) |
| **Công cụ** | pytest, pytest-asyncio; vitest + jsdom |
| **Phạm vi** | `modules/*/application/`, `ingestion/`, `platform/errors.py`, adapter Anthropic (client giả lập), `features/*/validate.ts`, `markdown.ts`, `shared/api/client.ts` |
| **Giả lập** | Fake port (`B:fakes/fakes.py`); không gọi mạng |
| **Tiêu chí vào** | Code xong, chạy được local |
| **Tiêu chí ra** | 100% unit test pass trong CI |

**Unit test hiện có:**

| Mã | Test | Yêu cầu | Trạng thái |
|---|---|---|---|
| UT-001 | `B:unit/test_chunker.py::test_long_page_is_split_within_limits_and_overlaps` | ADR-006 | ✅ |
| UT-002 | `::test_short_pages_are_merged_with_next` | ADR-006 | ✅ |
| UT-003 | `::test_chunks_never_span_two_normal_pages` | ADR-006 | ✅ |
| UT-004 | `::test_empty_pages_skipped_and_embed_text_has_prefix` | ADR-006 | ✅ |
| UT-005 | `B:unit/test_pdf_extractor.py::test_text_pdf_keeps_pages_and_vietnamese` | REQ-VN-01 | ✅ |
| UT-006 | `::test_rejected_files` (mã hóa, scan, hỏng) | FR-007 | ✅ |
| UT-007 | `::test_too_many_pages` | FR-007 | ✅ |
| UT-008 | `B:unit/test_errors_and_upload_helpers.py::test_app_error_is_problem_json` | API-CONTRACT | ✅ |
| UT-009 | `::test_normalize_filename_strips_paths_and_limits_length` | REQ-FN-01 | ✅ |
| UT-010 | `::test_retry_backoff` | NFR-021 | ✅ |
| UT-011 | `B:unit/test_ask_usecase.py::test_ok_outcome` | US-011 | ✅ |
| UT-012 | `::test_invalid_question` | AC-US-011-3 | ✅ |
| UT-013 | `::test_question_is_stripped_and_2000_chars_allowed` | AC-US-011-4 | ✅ |
| UT-014 | `::test_no_ready_documents_does_not_call_embedder` | AC-US-008-4 | ✅ |
| UT-015 | `::test_external_failure_is_error_outcome` | AC-US-011-8 | ✅ |
| UT-016 | `::test_prompt_contains_required_rules_and_context_format` | BRU-001, US-015 | ✅ |
| UT-017 | `B:unit/test_anthropic_adapter.py::test_failures_map_to_llm_unavailable` | AC-US-011-8 | ✅ |
| UT-018 | `::test_unrelated_type_error_is_not_swallowed` | AC-US-011-8 | ✅ |
| UT-019 | `::test_text_blocks_are_joined_and_thinking_ignored` | US-011 | ✅ |
| UT-020 | `::test_refusal_returns_not_found_answer` | BRU-001 | ✅ |
| UT-021 | `B:unit/test_eval_score.py::test_score_rates_and_ungraded` | KR2.1 | ✅ |
| UT-022 | `::test_not_found_detection` | KR2.3 | ✅ |
| UT-023 | `F:features/documents/validate.test.ts` (4 test: hợp lệ, > 10 tệp, sai loại / quá lớn, đổi đuôi) | BR-001, FR-007 | ✅ |
| UT-024 | `F:features/ask/validate.test.ts` (3 test: rỗng, hợp lệ, 2000 / 2001) | AC-US-011-3, 4 | ✅ |
| UT-025 | `F:features/ask/markdown.test.ts` (3 test: Markdown, `<img onerror>` / `<script>`, `javascript:`) | UXC-09 | ✅ |
| UT-026 | `F:shared/api/client.test.ts` (5 test: tiền tố, problem+json, 5xx không JSON, mạng, mã lạ) | API-CONTRACT, US-015 | ✅ |

**Unit test đề xuất bổ sung** (thực hiện quy tắc của `AGENTS.md`, không mở rộng phạm vi):

| Mã | Mô tả | Yêu cầu | Ưu tiên |
|---|---|---|---|
| UT-027 🆕 | Mọi khóa trong `ERRORS` và mọi `error_code` của ingestion đều có thông điệp trong `vi.json` | API-CONTRACT, AGENTS.md | P1 |

#### 6.3.2 Integration test

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | BE1 (F1, T-016), BE2 (F2, T-022) |
| **Công cụ** | pytest + Testcontainers (PostgreSQL 16 + pgvector), S3Mock, `httpx` ASGI client, `FakeLLM` |
| **Phạm vi** | API ↔ use case ↔ CSDL ↔ lưu trữ; hàng đợi và worker; truy xuất vector |
| **Tiêu chí vào** | Unit pass; Docker sẵn sàng; migration `0001_init` chạy được |
| **Tiêu chí ra** | 100% integration test (trừ `live`, `eval`) pass trong CI |

**Integration / API test:**

| Mã | Endpoint / thành phần | Loại | Kiểm tra | Kết quả mong đợi | Test | Trạng thái |
|---|---|---|---|---|---|---|
| INT-001 | `POST /api/v1/documents` | Positive | 3 PDF mẫu hợp lệ | 202, 3 item `queued`; sau ingest → `ready`, có chunk | `B:integration/test_documents.py::test_upload_three_valid_pdfs_then_ingest` | ✅ |
| INT-002 | `POST /api/v1/documents` | Negative | 11 tệp | 422 `too_many_files`, không lưu tệp nào | `::test_too_many_files_rejects_whole_batch` | ✅ |
| INT-003 | `POST /api/v1/documents` | Negative | 0 tệp | 422 `too_many_files` hoặc `question_invalid` (validation) — cần xác nhận mã đúng | 🆕 | ⏳ |
| INT-004 | `POST /api/v1/documents` | Negative | Lô trộn: `fake.pdf`, tệp 21 MB, tệp hợp lệ | 202; tệp lỗi có `not_pdf` / `file_too_large`; tệp hợp lệ `queued` | `::test_per_file_errors_do_not_block_valid_files` | ✅ |
| INT-005 | `POST /api/v1/documents` | Negative | Trùng tên tài liệu đã có | Item có `duplicate_name` | `::test_duplicate_name` | ✅ |
| INT-006 | `POST /api/v1/documents` | Biên | 49 tài liệu + 2 tệp | 409 `collection_full` | `::test_collection_full` | ✅ |
| INT-007 | Worker | Negative | `encrypted.pdf`, `scanned.pdf`, `corrupted.pdf`, `301_pages.pdf` | `failed` với `encrypted_pdf` / `no_text_layer` / `corrupted` / `too_many_pages` | `::test_bad_pdfs_fail_with_code` | ✅ |
| INT-008 | Worker | Độ tin cậy | Lỗi tạm thời lặp lại | Thử lại theo backoff rồi `failed` `transient_exhausted` | `::test_transient_errors_retry_then_give_up` | ✅ |
| INT-009 | Hàng đợi | Đồng thời | 2 worker cùng lấy việc | Không job nào bị lấy hai lần | `::test_two_workers_never_claim_the_same_job` | ✅ |
| INT-010 | Hàng đợi | Độ tin cậy | Job `running` quá hạn | Được thu hồi và xử lý lại | `::test_stale_running_job_is_reclaimed` | ✅ |
| INT-011 | `GET /api/v1/documents` | Positive | N tài liệu ở các trạng thái khác nhau | Đủ N item, sắp xếp `uploaded_at DESC`; `counts.processing` = `queued` + `processing`; `limit` = 50 | 🆕 (hiện chỉ kiểm gián tiếp trong INT-001) | ⏳ |
| INT-012 | `POST /api/v1/documents` | Lỗi hạ tầng | S3 trả lỗi khi `put_stream` | 502 `storage_error`; không có dòng `documents` mồ côi | 🆕 | ⏳ |
| INT-013 | Truy xuất | Positive | Câu hỏi khớp chunk tài liệu A; tài liệu B đang `processing` | A xếp đầu; không có chunk của B | `B:integration/test_ask.py::test_retrieval_ranks_relevant_chunk_and_skips_unready` | ✅ |
| INT-014 | `POST /api/v1/ask` | Positive | Câu hỏi hợp lệ, `FakeLLM` | 200 `{answer, latency_ms}`; `qa_log` đúng tập cột, không có nội dung | `::test_ask_returns_answer_and_logs_without_content` | ✅ |
| INT-015 | `POST /api/v1/ask` | Negative | Rỗng / 2001 ký tự | 422 `question_invalid` | `::test_invalid_question` | ✅ |
| INT-016 | `POST /api/v1/ask` | Negative | Body không phải JSON / thiếu trường `question` | 422 `question_invalid` (problem+json) | 🆕 | ⏳ |
| INT-017 | `POST /api/v1/ask` | Negative | Không có tài liệu `ready` | 409 `no_documents` | `::test_no_ready_documents` | ✅ |
| INT-018 | `POST /api/v1/ask` | Lỗi phụ thuộc | `FakeLLM` ném lỗi | 503 `ai_unavailable`; `qa_log.status='error'` | `::test_llm_failure_is_503_and_logged` | ✅ |
| INT-019 | `POST /api/v1/ask` | Lỗi phụ thuộc | TEI không phản hồi | 503 `ai_unavailable`; `qa_log.status='error'` | 🆕 | ⏳ |
| INT-020 | Toàn API | Hợp đồng | Lỗi không lường trước | 500 `internal_error`, problem+json, không lộ stack trace | 🆕 | ⏳ |
| INT-021 | `/healthz` | Positive | Stack chạy | 200 | Smoke trong `deploy.sh` | 🖐 |
| INT-022 | `POST /api/v1/ask` | Live | Claude thật, 3 PDF mẫu (marker `live`) | Câu trả lời tiếng Việt, khớp tài liệu mẫu | 🆕 `pytest -m live` | ⏳ |

#### 6.3.3 Kiểm thử hệ thống / E2E

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | FE + QA |
| **Công cụ** | Playwright (Chrome). Hiện chưa có test E2E tự động; đề xuất thêm vào phạm vi T-015 / T-021 (đặc tả hai task đã ghi "Playwright") |
| **Phạm vi** | Luồng người dùng trên stack local đầy đủ (`make dev`); kịch bản cần lỗi AI dùng route mock của Playwright |
| **Tiêu chí vào** | Integration pass; `make dev` healthy; T-015 và T-021 xong |
| **Tiêu chí ra** | E2E P0 đạt 100%; E2E P1 đạt hoặc có lỗi được PO chấp nhận |

| Mã | Kịch bản | Các bước | Kết quả mong đợi | Yêu cầu | Ưu tiên |
|---|---|---|---|---|---|
| E2E-001 | Tải lên và theo dõi trạng thái | 1. Mở `/documents` khi trống. 2. Chọn 3 PDF mẫu + `fake.pdf`. 3. Chờ, không tải lại trang | Nút hiện "Đang tải lên…"; `fake.pdf` báo "Không phải tệp PDF hợp lệ"; 3 tệp đi từ Đang chờ → Đang xử lý → Sẵn sàng; mỗi tệp có 1 toast "[tên] đã sẵn sàng"; số trên sidebar = 3; ngày dạng `dd/mm/yyyy` | US-005, 006, 007 | P0 |
| E2E-002 | Tệp lỗi sau ingestion | Tải `encrypted.pdf`, `scanned.pdf`, `corrupted.pdf` | Badge Lỗi kèm "Tệp có mật khẩu", "PDF dạng ảnh chưa được hỗ trợ", "Tệp bị hỏng"; các tài liệu khác không đổi trạng thái | FR-007, NFR-021 | P0 |
| E2E-003 | Kiểm tra phía client | Chọn 11 tệp; chọn 1 tệp > 20 MB cùng 1 tệp hợp lệ | 11 tệp → banner lỗi, không gửi request; tệp lớn báo "Vượt quá 20 MB", tệp hợp lệ vẫn được gửi | BR-001 | P1 |
| E2E-004 | Chưa có tài liệu Sẵn sàng | Mở `/ask` khi `counts.ready = 0` | Ô nhập bị khóa; hiện "Tải lên tài liệu để bắt đầu" có link `/documents` | AC-US-008-4, EC-01 | P0 |
| E2E-005 | Hỏi và nhận câu trả lời | 1. Có ≥ 1 tài liệu Sẵn sàng. 2. Nhập câu hỏi, nhấn Enter | Bong bóng câu hỏi; spinner "Đang tìm câu trả lời…" + "Có thể mất tới 20 giây"; câu trả lời Markdown kèm nhãn "Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc" | US-011, US-015 | P0 |
| E2E-006 | Kiểm tra ô nhập | Gõ chỉ khoảng trắng; dán 2001 ký tự; Shift+Enter | Nút Gửi khóa khi rỗng hoặc > 2000; bộ đếm `n/2000` đúng; Shift+Enter xuống dòng, không gửi | AC-US-011-3, 4, EC-12 | P1 |
| E2E-007 | Lỗi AI và Hỏi lại | Mock `/api/v1/ask` trả 503, sau đó trả 200 | Hiện "Hệ thống đang bận, vui lòng thử lại" + nút Hỏi lại, không có lỗi kỹ thuật thô; bấm Hỏi lại → nhận câu trả lời | AC-US-011-8, EC-06 | P0 |
| E2E-008 | XSS trong câu trả lời | Mock câu trả lời chứa `<img src=x onerror=alert(1)>`, `<script>`, link `javascript:` | Không có hộp thoại `alert`, không có thẻ `script` trong DOM, link bị vô hiệu | UXC-09 | P0 |
| E2E-009 | Lịch sử chỉ trong bộ nhớ trang | Hỏi 2 câu, tải lại trang | Hai cặp hỏi–đáp hiển thị theo thứ tự; sau khi tải lại thì mất (đúng thiết kế) | T-021 | P2 |

#### 6.3.4 Đánh giá chất lượng AI (golden eval)

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | QA + BD (chấm), BE1 + BE2 (sửa) |
| **Công cụ** | `make eval BASE_URL=…`, chấm cột `correct`, `make eval-score` |
| **Dữ liệu** | Bộ PDF mẫu của BD + ≥ 30 câu positive + ≥ 10 câu negative (hạn bàn giao 05/11/2026). Golden set hiện chỉ có 4 positive + 2 negative mẫu |
| **Môi trường** | AWS (cấu hình giống production), Claude thật |
| **Tần suất** | Hằng ngày trong tuần ổn định; bắt buộc chạy lại khi sửa `prompts.py`, `QA_TOP_N`, chunker hoặc model, kèm điểm trước / sau trong PR |
| **Tiêu chí ra** | KR2.1 ≥ 80%, KR2.3 ≥ 90% tại hạn 26/11, hoặc PO đã có quyết định go / no-go |

| Mã | Đo | Phương pháp | Ngưỡng | Yêu cầu |
|---|---|---|---|---|
| EVAL-001 | Tỷ lệ trả lời đúng (câu positive) | BD / QA chấm `correct` 0/1 theo `expected_answer` | ≥ 80% | KR2.1, AC-US-011-1 |
| EVAL-002 | Tỷ lệ "không tìm thấy" (câu negative) | `score.py` tự phát hiện cụm "không tìm thấy" | ≥ 90% | KR2.3, AC-US-014-1 |
| EVAL-003 | Không bịa ở câu negative | QA đọc câu trả lời negative: không kèm nội dung suy diễn | 0 câu bịa có hại | BRU-001 |
| EVAL-004 | Ngôn ngữ trả lời | QA kiểm tra mọi câu trả lời là tiếng Việt | 100% | US-015 |
| EVAL-005 | Độ trễ | `latency_ms` trong CSV kết quả | p90 ≤ 15 s | NFR-001 |

**Quy tắc chấm:** một câu positive được tính đúng khi câu trả lời chứa đủ ý chính trong `expected_answer` và không có thông tin sai. Nếu hai người chấm khác nhau, PO quyết định.

#### 6.3.5 Kiểm thử chấp nhận (UAT)

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | ≥ 2 đại diện BD, PO; QA điều phối |
| **Thời gian** | Thứ Năm 26/11/2026, trên AWS, với tag ứng viên go-live |
| **Tiêu chí vào** | E2E P0 đạt; EVAL-001, 002 đã có kết quả; SEC-001..003 đạt; hướng dẫn sử dụng đã có |
| **Tiêu chí ra** | Biên bản `docs/implement/evidence/UAT.md` được ký |

| Mã | Kịch bản | Tiêu chí đạt | Yêu cầu |
|---|---|---|---|
| UAT-001 | Tải lên các PDF của dự án (tài liệu thật nếu OQ-008 cho phép) | Tất cả Sẵn sàng hoặc báo lỗi rõ lý do | US-005, 006, 007 |
| UAT-002 | Tải 1 PDF scan và 1 PDF có mật khẩu | Thông báo lỗi dễ hiểu với người dùng BD | US-007 |
| UAT-003 | Hỏi 10 câu thường gặp trong công việc | ≥ 8 câu trả lời dùng được | US-011, KR2.1 |
| UAT-004 | Hỏi 3 câu không có trong tài liệu | 3/3 nhận "Không tìm thấy thông tin…" | US-014, KR2.3 |
| UAT-005 | Truy cập từ mạng ngoài công ty (4G) | Không truy cập được | SEC-NET |
| UAT-006 | Đọc hướng dẫn sử dụng 1 trang | BD tự tải PDF và hỏi được mà không cần hỗ trợ | T-024 |

#### 6.3.6 Hồi quy

| Thuộc tính | Mô tả |
|---|---|
| **Kích hoạt** | Mỗi PR và mỗi lần push lên `main`; trước mỗi lần deploy |
| **Cách làm** | Toàn bộ suite tự động trong CI; golden eval trước deploy khi có thay đổi ảnh hưởng câu trả lời; smoke sau deploy |

| Suite | Phạm vi | Số test | Thời gian ước tính | Tự động |
|---|---|---|---|---|
| REG-001 | Unit backend | 22 hàm test | < 1 phút | ✓ CI |
| REG-002 | Integration backend (Testcontainers) | 14 hàm test | 2–4 phút | ✓ CI |
| REG-003 | Unit frontend (vitest) | 15 | < 1 phút | ✓ CI |
| REG-004 | E2E Playwright (🆕) | 9 | 10–15 phút (TEI CPU) | ✓ (job riêng) |
| REG-005 | Golden eval | ≥ 40 câu | 10–15 phút + thời gian chấm | Bán tự động |
| REG-006 | Smoke sau deploy: `/healthz`, `GET /documents`, 1 câu hỏi mẫu | 3 | < 2 phút | Bán tự động |

#### 6.3.7 Hiệu năng

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | BE2 + QA |
| **Công cụ** | `make eval` (latency), truy vấn `qa_log`, script đo thời gian ingestion (đọc `documents` theo thời điểm), `docker stats` |
| **Môi trường** | AWS (`m7i.2xlarge`, RDS `db.t4g.medium`). Số đo trên Mac (TEI giả lập x86) chỉ để tham khảo |
| **Tiêu chí vào** | Bản build ổn định trên AWS; bộ 50 tài liệu đã nạp cho PERF-002 |

| Mã | Kịch bản | Tải | Chỉ số | Ngưỡng | Yêu cầu | Ưu tiên |
|---|---|---|---|---|---|---|
| PERF-001 | Ingestion PDF văn bản 50 trang | 1 tệp, hàng đợi rỗng | Thời gian từ 202 đến `ready` | ≤ 60 s | NFR-003 | P1 |
| PERF-002 | Thời gian trả lời | Golden set tuần tự, bộ 50 tài liệu | p90 `latency_ms` | ≤ 15 s (PO có thể chấp nhận ≤ 20 s theo Implement_plan) | NFR-001 | P1 |
| PERF-003 | Tải lên lô lớn | 10 tệp × 20 MB, một request | RAM tăng thêm của container `api` | ≤ 100 MB; request thành công qua Nginx | T-009 | P1 |
| PERF-004 | AI không phản hồi | Chặn mạng ra Anthropic (hoặc trỏ `base_url` tới endpoint treo) | Thời gian đến khi UI hiện "Hệ thống đang bận…" | ≤ 30 s | NFR-020, EC-06 | P1 |

> **Lưu ý cho PERF-004:** cấu hình hiện tại `llm_timeout_s = 60` với `max_retries = 2` của SDK. Thời gian chờ xấu nhất vì vậy có thể vượt 60 s, còn Nginx cắt ở `proxy_read_timeout 90s`. Mức này **dự kiến không đạt** ngưỡng 30 s của NFR-020. Cần Tech lead và PO quyết định: giảm timeout và retry, hoặc chấp nhận lệch và cập nhật NFR-020 (xem RISK-008).

#### 6.3.8 Kiểm tra bảo mật theo tiêu chí task

> Rà soát bảo mật riêng và quét bảo mật trong CI đã bị lược bỏ ở v0.4. Mục này chỉ kiểm các tiêu chí bảo mật đã có trong task (T-006, T-009, T-021) và quy tắc không log nội dung (CN-06).

| Thuộc tính | Mô tả |
|---|---|
| **Phụ trách** | Tech lead + QA |
| **Công cụ** | Trình duyệt / `curl` từ mạng ngoài, `openssl s_client`, AWS Console / CLI |
| **Tiêu chí ra** | 0 lỗi Blocker / Critical; mọi lỗi High có kế hoạch xử lý được PO chấp nhận |

| Mã | Kiểm tra | Mô tả | Kết quả mong đợi | Yêu cầu | Ưu tiên |
|---|---|---|---|---|---|
| SEC-001 | Giới hạn mạng | Truy cập `https://<domain>/` và `/api/v1/documents` từ 4G và từ một VPS ngoài; rà soát inbound rules của `sg-alb` | Không kết nối được; không có rule `0.0.0.0/0` | SEC-NET | P0 |
| SEC-002 | TLS | Kiểm tra phiên bản giao thức, chứng chỉ ACM; truy cập `http://` | Chỉ TLS ≥ 1.2; 80 chuyển hướng 443 | NFR-010 | P0 |
| SEC-003 | Mã hóa at-rest | Kiểm tra S3 (SSE-KMS, Block Public Access, policy bắt buộc TLS), RDS (KMS), `S3_USE_KMS=true` | Đúng cấu hình T-006 | NFR-011 | P0 |
| SEC-004 | XSS | UT-025 và E2E-008 | Không thực thi script | UXC-09 | P0 |
| SEC-005 | An toàn tải tệp (T-009) | Tên tệp `../../etc/passwd.pdf`, tên dài 300 ký tự, Unicode tổ hợp; nội dung không phải PDF với đuôi `.pdf`; tệp 21 MB | Tên được chuẩn hóa; khóa S3 chỉ dùng `documents/{uuid}.pdf`; `not_pdf` / `file_too_large` | REQ-FN-01, F1.1 | P1 |
| SEC-006 | Không log nội dung | Sau UAT, tìm trong CloudWatch `/cwd/prod` một chuỗi đặc trưng của câu hỏi và tài liệu UAT; kiểm tra cột của `qa_log` | Không tìm thấy nội dung; `qa_log` chỉ có số liệu | CN-06, PRD §6.2 | P0 |

#### 6.3.9 Giao diện

Kiểm thử a11y đã bị lược bỏ ở v0.4. Mục này chỉ đối chiếu giao diện với đặc tả T-015, T-021 và quy tắc chuỗi giao diện của `AGENTS.md`.

| Mã | Kiểm tra | Kết quả mong đợi | Ưu tiên |
|---|---|---|---|
| UI-001 | So màn hình Tài liệu và Hỏi đáp với `html_design/03-documents.html`, `04-chat.html` (trừ phần đã lược bỏ ở T-015, T-021) | Bố cục, màu và nhãn tương đương; không có thành phần đã bỏ (trích dẫn, kéo-thả, nút gỡ, nút Dừng) | P1 |
| UI-002 | Không có chuỗi giao diện viết cứng | Rà soát TSX: mọi chuỗi hiển thị lấy từ `vi.json` | P1 |
| UI-003 | Badge trạng thái | Có icon và chữ cho 4 trạng thái | P1 |

#### 6.3.10 Vận hành và triển khai

| Mã | Kiểm tra | Kết quả mong đợi | Yêu cầu | Ưu tiên |
|---|---|---|---|---|
| OPS-001 | `make dev` trên máy sạch (Docker ≥ 8 GB RAM) | Đủ dịch vụ healthy: postgres, s3, tei, api, worker ×2, web | OPS-LOCAL | P1 |
| OPS-002 | `make seed` | 3 PDF mẫu được nhận và chuyển Sẵn sàng | OPS-LOCAL | P2 |
| OPS-003 | PR thử trên GitHub | Job `backend`, `frontend` xanh; PR có lỗi lint bị chặn merge | OPS-CI | P0 |
| OPS-004 | Push lên `main` | Image `api`, `web` tag `sha-<short>` có trên ECR | OPS-CI | P0 |
| OPS-005 | `infra/deploy.sh <tag>` | `alembic upgrade head` thành công; `curl -f /healthz` 200; lưu `.last_tag` | OPS-DEPLOY | P0 |
| OPS-006 | `infra/rollback.sh` | Quay về tag trước trong < 10 phút; dữ liệu còn nguyên | OPS-DEPLOY | P0 |
| OPS-007 | Khởi động lại container `worker` khi đang xử lý | Job được thu hồi và hoàn tất; không mất tài liệu | ADR-010 | P1 |
| OPS-008 | Thiếu `ANTHROPIC_API_KEY` | `/ask` trả 503 `ai_unavailable`; phần còn lại hoạt động | AC-US-011-8 | P1 |
| OPS-009 | Truy vấn số liệu pilot trong README | Chạy được trên RDS, trả số câu hỏi và p90 theo tuần | PRD §6.2 | P2 |

### 6.4 Quản lý lỗi

| Mức độ | Định nghĩa | Ví dụ | Thời hạn xử lý |
|---|---|---|---|
| **Blocker** | Chặn luồng chính hoặc gây lộ dữ liệu; không có cách vòng | Truy cập được từ mạng ngoài; tải lên luôn lỗi; XSS thực thi | Ngay, chặn go-live |
| **Critical** | Sai chức năng P0, có cách vòng khó | Tài liệu `processing` bị dùng làm nguồn; mất tài liệu khi restart worker | ≤ 1 ngày, chặn go-live |
| **Major** | Sai chức năng P1 hoặc trải nghiệm kém rõ rệt | Toast không hiện; thông điệp lỗi sai mã; p90 > 20 s | Trước go-live hoặc PO chấp nhận |
| **Minor** | Lỗi hiển thị, câu chữ | Lệch căn lề, lỗi chính tả trong `vi.json` | Trong pilot |

- Lỗi được ghi thành GitHub Issue có nhãn `bug`, mức độ, mã test case, mã task và bước tái hiện.
- Sửa lỗi dùng mã task gốc trong tiêu đề commit (ví dụ `T-015: Fix toast not shown after ready`), kèm test hồi quy khi có thể.
- Lỗi chất lượng câu trả lời ghi vào CSV kết quả eval theo nhóm của T-023 (truy xuất sai / trả lời sai / bịa), không mở Issue riêng cho từng câu.

---

## 7. Tiêu chí đạt / không đạt (IEEE 829 §5.7)

### 7.1 Mức test case

- **Đạt:** kết quả thực tế khớp kết quả mong đợi, gồm mã HTTP, `code` lỗi, trạng thái tài liệu và thông điệp tiếng Việt.
- **Không đạt:** bất kỳ sai lệch nào. Test bị chặn vì môi trường thì ghi **Blocked**, không tính là Đạt.
- **Test không ổn định (flaky):** test fail ≥ 2 lần trong 10 lần chạy lặp được đánh dấu và sửa trong 2 ngày. Không được bỏ qua bằng `skip` nếu PO chưa đồng ý.

### 7.2 Mức hạng mục / phát hành (cổng go-live 27/11/2026)

| # | Tiêu chí | Ngưỡng | Bắt buộc |
|---|---|---|---|
| 1 | CI trên tag ứng viên | `backend` và `frontend` xanh (100% unit + integration) | ✓ |
| 2 | E2E P0 (E2E-001, 002, 004, 005, 007, 008) | 100% đạt | ✓ |
| 3 | Lỗi mở | 0 Blocker, 0 Critical; Major phải có PO chấp nhận bằng văn bản | ✓ |
| 4 | EVAL-001 (KR2.1) | ≥ 80% | ✓ (hoặc PO quyết định go có điều kiện) |
| 5 | EVAL-002 (KR2.3) | ≥ 90% | ✓ (hoặc PO quyết định go có điều kiện) |
| 6 | SEC-001, 002, 003, 006 | Đạt | ✓ |
| 7 | OPS-003, 005, 006 | Đạt | ✓ |
| 8 | UAT | Biên bản ký: UAT-003 ≥ 8/10, UAT-004 3/3, UAT-005 đạt | ✓ |
| 9 | PERF-001, PERF-002, PERF-003 | Đạt ngưỡng hoặc PO chấp nhận số đo | P1 |
| 10 | PERF-004 (NFR-020) | ≤ 30 s, hoặc PO chấp nhận lệch và cập nhật NFR-020 | P1 |
| 11 | Truy vết | Mọi yêu cầu P0 trong Phụ lục A có trạng thái ✅ hoặc 🖐 đã ký trong UAT | ✓ |

> Ngưỡng có dấu ⚑ trong PRD là giá trị đề xuất. PO có quyền điều chỉnh tại buổi go / no-go, nhưng phải ghi lại lý do trong biên bản.

---

## 8. Tiêu chí tạm dừng và tiếp tục (IEEE 829 §5.8)

| # | Tạm dừng khi | Phạm vi dừng | Điều kiện tiếp tục |
|---|---|---|---|
| S-1 | Phát hiện truy cập được từ mạng ngoài, hoặc nghi lộ dữ liệu tài liệu | **Dừng toàn bộ** kiểm thử trên AWS; Tech lead đóng ALB | Security group đã sửa; SEC-001 chạy lại và đạt; PO được thông báo |
| S-2 | Build không deploy được hoặc `/healthz` lỗi trên môi trường kiểm thử | Toàn bộ kiểm thử trên môi trường đó | Bản sửa đã deploy; smoke REG-006 đạt |
| S-3 | Lỗi Blocker ở luồng tải lên hoặc hỏi đáp | Kiểm thử phụ thuộc luồng đó | Bản sửa đã merge kèm test hồi quy; chạy lại các test bị chặn |
| S-4 | > 30% integration test fail vì hạ tầng (Testcontainers, Docker, TEI hết bộ nhớ) | Kiểm thử integration / E2E | Môi trường dựng lại sạch; OPS-001 đạt |
| S-5 | Không có `ANTHROPIC_API_KEY` hoặc OQ-008 cấm gửi dữ liệu | EVAL, INT-022, UAT-003, UAT-004, PERF-002 | Có khóa API, hoặc adapter thay thế (Bedrock / LLM tự vận hành) đã qua UT-017..020 với adapter mới |
| S-6 | Chưa có golden set của BD | EVAL-001, EVAL-002 | BD bàn giao; nếu trễ quá 05/11 thì dùng bộ tạm 20 câu do BA soạn (Implement_plan §3) |
| S-7 | Vượt hạn mức chi tiêu Anthropic | Mọi kiểm thử gọi Claude thật | PO duyệt nâng hạn mức |

---

## 9. Sản phẩm bàn giao của kiểm thử (IEEE 829 §5.9)

| Sản phẩm | Mô tả | Vị trí | Phụ trách | Thời điểm |
|---|---|---|---|---|
| Kế hoạch kiểm thử | Tài liệu này | `docs/07-verification/Test_Plan.md` | QA | 02/11 (review) |
| Đặc tả test case | Mục 6.3 và Phụ lục A; mã nguồn test | `backend/tests/`, `frontend/src/**/*.test.ts`, `frontend/e2e/` | Dev + QA | Theo task |
| Test case cho agent (localhost) | 77 file, mỗi file một test case: bước, kết quả mong đợi, script gợi ý, yêu cầu bằng chứng | `docs/07-verification/test_cases/` | QA | 02/11 |
| Bằng chứng thực thi | Mỗi test case một thư mục: `report.md`, `video.webm`, `screenshots/`, `logs/` | `test_reports/<ID>/` | Agent / QA | Mỗi lần chạy |
| Dữ liệu kiểm thử | Fixture PDF, golden set | `B:fixtures/`, `B:eval/golden.yaml` | BE1, BD | 05/11, 16/11 |
| Log thực thi | Kết quả CI, CSV eval | GitHub Actions, `B:eval/results/*.csv` | CI, QA | Liên tục |
| Báo cáo sự cố | GitHub Issues nhãn `bug` | GitHub | Mọi người | Liên tục |
| Ma trận truy vết | Cập nhật trạng thái | `docs/implement/traceability.md` | TL | Mỗi PR có test |
| Biên bản UAT | Đã ký | `docs/implement/evidence/UAT.md` | QA / PO | 26/11 |
| Báo cáo tổng kết kiểm thử | Tổng hợp kết quả (gồm số đo PERF-001..004 và SEC-001..006), lỗi còn mở, khuyến nghị go / no-go | `docs/07-verification/Test_Summary_Report.md` | QA | 27/11 |

---

## 10. Công việc kiểm thử (IEEE 829 §5.10)

| # | Công việc | Task liên quan | Phụ trách | Phụ thuộc | Hạn |
|---|---|---|---|---|---|
| TT-01 | Review và phê duyệt kế hoạch kiểm thử | — | PO, TL | — | 02/11 |
| TT-02 | Xác nhận CI chạy lần đầu (OPS-003, 004) | T-003 | TL | T-001 | 06/11 |
| TT-03 | Gửi template golden set cho BD; nhận bàn giao | T-008 | QA + BA | — | 05/11 |
| TT-04 | Viết unit test theo từng task (UT-*) | T-009..T-021 | Dev | — | Theo task |
| TT-05 | Hoàn thiện integration F1 (INT-001..012) | T-016 | BE1 | T-009, T-013 | 18/11 |
| TT-06 | Hoàn thiện integration F2 (INT-013..020) | T-022 | BE2 | T-020 | 19/11 |
| TT-07 | Bổ sung UT-027 | T-007 | FE | — | 19/11 |
| TT-08 | Viết E2E Playwright E2E-001..009 | T-015, T-021 | FE + QA | T-015, T-021 | 20/11 |
| TT-09 | Chạy test `live` (INT-022) | T-022 | BE2 | Khóa API | 20/11 |
| TT-10 | Dựng và nạp dữ liệu kiểm thử trên AWS | T-006 | TL | T-006 | 20/11 |
| TT-11 | Golden eval hằng ngày, phân loại lỗi, sửa | T-023 | QA, BE1, BE2 | TT-03, TT-10 | 23–26/11 |
| TT-12 | Kiểm thử hiệu năng PERF-001..004 | T-023 | BE2 + QA | TT-10 | 24/11 |
| TT-13 | Kiểm tra bảo mật SEC-001..006 | T-006, T-024 | TL + QA | TT-10 | 24/11 |
| TT-14 | Kiểm thử vận hành OPS-005..008 | T-006 | TL | TT-10 | 24/11 |
| TT-16 | Chạy UAT, lập biên bản | T-024 | QA, PO, BD | TT-11..14 | 26/11 |
| TT-17 | Báo cáo tổng kết kiểm thử; họp go / no-go | T-024 | QA, PO, TL, Quản lý | TT-16 | 27/11 |
| TT-18 | **Dọn dữ liệu kiểm thử trên AWS** (xóa tài liệu test trong DB và S3; tài liệu test chiếm giới hạn 50) | T-024 | TL | TT-17 | 27/11 |
| TT-19 | Smoke sau deploy go-live (REG-006, SEC-001); theo dõi log 2 giờ đầu | T-024 | TL + QA | TT-18 | 30/11 |
| TT-20 | Theo dõi pilot: số câu hỏi, p90 trong `qa_log` theo tuần | — | TL | TT-19 | 30/11 → 31/12 |

---

## 11. Nhu cầu môi trường (IEEE 829 §5.11)

### 11.1 Môi trường

| Môi trường | Mục đích | Cấu hình | Dữ liệu |
|---|---|---|---|
| **Local** (máy developer) | Unit, integration, E2E khi phát triển | Docker Desktop ≥ 8 GB RAM; `make dev`: postgres (pgvector), S3Mock (volume `s3data`), TEI CPU `bge-m3` (chỉ có bản amd64, trên Apple Silicon chạy giả lập, lần đầu tải ~2,3 GB, `--max-batch-tokens 2048`), api, worker ×2, web | Fixture giả lập |
| **CI** (GitHub Actions) | Hồi quy mỗi PR | Ubuntu, Python 3.12, Node 20, Docker cho Testcontainers; `pytest -m "not eval and not live"` | Fixture giả lập; `FakeLLM` |
| **AWS** (môi trường duy nhất, cũng là production) | Eval, hiệu năng, bảo mật, UAT, go-live | EC2 `m7i.2xlarge` (Docker Compose: web / Nginx, api, worker, tei); RDS PostgreSQL 16 `db.t4g.medium` + `vector`; S3 `cwd-documents-prod` SSE-KMS; ALB HTTPS giới hạn IP; Secrets Manager; CloudWatch `/cwd/prod` | Bộ PDF mẫu của BD; tài liệu thật chỉ khi OQ-008 cho phép |

> **Hệ quả của việc chỉ có một môi trường AWS:** kiểm thử trước go-live chạy trên chính hạ tầng production. Vì vậy (1) mọi tài liệu và dòng `qa_log` sinh ra khi kiểm thử phải được dọn ở TT-18; (2) không chạy test phá hủy (OPS-007) sau go-live khi chưa báo đội BD.

### 11.2 Công cụ

| Công cụ | Mục đích | Trạng thái |
|---|---|---|
| pytest, pytest-asyncio, Testcontainers | Unit, integration backend | Có |
| vitest + jsdom | Unit frontend | Có |
| Playwright + Chrome | E2E | **Cần thêm** vào `frontend/devDependencies` |
| `openssl` | SEC-002 | Có sẵn trên macOS / Linux |
| `run_eval.py`, `score.py` | Golden eval | Có |

### 11.3 Truy cập và bí mật cần có

- `ANTHROPIC_API_KEY` dành cho kiểm thử, có hạn mức chi tiêu, sau quyết định OQ-008.
- Quyền đọc AWS Console (S3, RDS, EC2 security group, CloudWatch) cho QA.
- Một thiết bị ngoài mạng công ty (4G) cho SEC-001, UAT-005.
- Danh sách CIDR / VPN của IT đã áp dụng vào `sg-alb`.

---

## 12. Trách nhiệm (IEEE 829 §5.12)

| Vai trò | Người | Trách nhiệm kiểm thử |
|---|---|---|
| **PO** | Huy Toan | Phê duyệt kế hoạch; chấp nhận rủi ro và lỗi Major; quyết định ngưỡng ⚑; chủ trì UAT; ký go / no-go |
| **Tech lead (TL)** | Huy Toan | CI, môi trường AWS, SEC-*, OPS-*, dọn dữ liệu, cập nhật `traceability.md`; review mọi PR có test |
| **BE1** | [TBD] | Unit + integration F1 (T-016), fixture PDF, PERF-001, PERF-003 |
| **BE2** | [TBD] | Unit + integration F2 (T-022), test `live`, PERF-002, PERF-004 |
| **FE** | [TBD] | Unit frontend, E2E Playwright, UI-001..004 |
| **QA** | [TBD] (có thể do BE1 kiêm khi thiếu người) | Điều phối kế hoạch; chấm eval; quản lý lỗi; báo cáo tổng kết |
| **BD (≥ 2 đại diện)** | [TBD] | Bàn giao bộ PDF mẫu và golden set; chấm câu positive; thực hiện UAT |
| **BA** | [TBD] | Soạn bộ câu hỏi tạm nếu BD giao trễ |
| **Quản lý** | [TBD] | Duyệt 4 đánh đổi của v0.4; tham dự go / no-go |
| **IT** | [TBD] | Cung cấp dải IP / VPN |

---

## 13. Nhân sự và đào tạo (IEEE 829 §5.13)

| Nhu cầu | Đối tượng | Hình thức | Thời điểm |
|---|---|---|---|
| Testcontainers, fake port, cấu trúc hexagonal của repo | Dev mới, QA | Đọc `AGENTS.md`, `B:integration/conftest.py`, `B:fakes/fakes.py`; pair 1 giờ | Tuần S0 |
| Viết test Playwright cho SPA React, mock route API | FE, QA | Tự học, 0,5 ngày | Trước 16/11 |
| Đánh giá câu trả lời RAG: thế nào là "đúng", "bịa", "dùng được" | BD, QA | Buổi hướng dẫn 30 phút kèm 5 ví dụ đã chấm | Khi bàn giao golden set |
| Hiểu giới hạn MVP (không trích dẫn, không đăng nhập, chờ 10–20 s) | BD tham gia UAT | Hướng dẫn sử dụng 1 trang + giới thiệu 15 phút đầu buổi UAT | 26/11 |
| Kiểm tra cấu hình AWS (security group, KMS) | QA | TL hướng dẫn 30 phút | Trước 24/11 |

**Ước lượng công sức kiểm thử:** khoảng 7 ngày công đã nằm trong 24 task (T-008, T-016, T-022, T-023, T-024, một phần T-003 / T-006). E2E Playwright thuộc mục "Kiểm thử" của T-015 và T-021. Phần kế hoạch này đề xuất thêm (UT-027, INT-003 / 011 / 012 / 016 / 019 / 020, báo cáo tổng kết) khoảng 1 ngày, cần PO xác nhận.

---

## 14. Lịch kiểm thử (IEEE 829 §5.14)

| Giai đoạn | Thời gian | Hoạt động kiểm thử | Mốc dự án | Cổng ra |
|---|---|---|---|---|
| Chuẩn bị | 31/10 → 02/11 | Soạn và review kế hoạch kiểm thử | — | TP-CWD-001 được duyệt |
| **S0 — Nền tảng** | 02/11 → 06/11 | CI chạy lần đầu (OPS-003, 004); OPS-001; nhận golden set (05/11); unit cho platform | **M0** Local + AWS chạy; CI xanh | CI xanh trên `main` |
| **S1 — Phát triển** | 09/11 → 20/11 | Unit theo task; integration F1 (18/11), F2 (19/11); E2E (20/11); `live` (20/11); nạp dữ liệu lên AWS | **M1** Tải PDF → hỏi → nhận câu trả lời trên AWS (20/11) | Integration + E2E P0 đạt |
| **Ổn định** | 23/11 → 25/11 | Eval hằng ngày; PERF-*; SEC-*; OPS-005..008 | — | Đủ đầu vào cho UAT |
| Hạn chất lượng | 26/11 | Kết quả eval cuối cho PO; **UAT** | **M2** UAT ký xác nhận | Biên bản UAT |
| Go / no-go | 27/11 | Báo cáo tổng kết kiểm thử; họp; dọn dữ liệu test | — | Quyết định go |
| **Go-live** | 30/11 | Smoke sau deploy; SEC-001; theo dõi log 2 giờ | **M3** | Smoke đạt |
| Pilot | 30/11 → 31/12 | Theo dõi `qa_log` hằng tuần; ghi nhận lỗi từ người dùng | **M4** Báo cáo đánh giá 08/01/2027 | — |

**Đường găng kiểm thử:** T-020 → T-022 → TT-10 (dữ liệu trên AWS) → TT-11 (eval) → UAT. Nếu golden set hoặc khóa API trễ, EVAL-001 / 002 không đủ ngày đo trước 26/11.

---

## 15. Rủi ro và phương án dự phòng (IEEE 829 §5.15)

| Mã | Rủi ro (đối với kiểm thử) | Khả năng | Ảnh hưởng | Điểm | Giảm thiểu | Dự phòng |
|---|---|---|---|---|---|---|
| RISK-001 | OQ-008 không cho gửi dữ liệu tới Anthropic API → không chạy được eval và UAT với Claude thật | 3 | 5 | 15 | Quyết định trước 06/11; adapter tách qua `LLMPort` | Đổi adapter Bedrock (~1 ngày) và chạy lại UT adapter + eval; nếu phải tự vận hành LLM thì lùi lịch kiểm thử ~1 tuần |
| RISK-002 | Chất lượng câu trả lời không đạt KR2.1 / KR2.3 trước 26/11 | 4 | 5 | 20 | Eval hằng ngày từ 23/11; phân loại lỗi theo T-023 | PO quyết định go có điều kiện (nhấn mạnh nhãn "hãy đối chiếu tài liệu gốc") hoặc lùi go-live |
| RISK-003 | BD bàn giao golden set trễ hoặc ít câu | 3 | 4 | 12 | Nhắc từ 27/10; hạn 05/11 | Bộ tạm 20 câu do BA soạn; kết quả ghi rõ "chưa đại diện" |
| RISK-004 | Không có E2E tự động; T-015 / T-021 nghiệm thu chỉ bằng chạy thử | 4 | 3 | 12 | TT-08 thêm Playwright | Chạy E2E-001..009 thủ công theo checklist và ghi bằng chứng ảnh chụp |
| RISK-005 | CI chưa từng chạy trên GitHub; job build cần secret `AWS_DEPLOY_ROLE_ARN` | 3 | 4 | 12 | TT-02 trong S0 | Chạy `make lint` + `make test` local làm cổng tạm, ghi log vào PR |
| RISK-006 | TEI giả lập trên Mac chậm hoặc hết bộ nhớ làm integration / E2E local chập chờn | 4 | 2 | 8 | `--max-batch-tokens 2048`; Docker ≥ 8 GB | Chạy E2E trên CI (amd64) hoặc trên EC2 |
| RISK-007 | Chỉ có một môi trường AWS: dữ liệu test lẫn dữ liệu thật; test chiếm giới hạn 50 tài liệu | 4 | 3 | 12 | Đặt tiền tố `TEST_` cho tệp test; TT-18 dọn dữ liệu | Tech lead xóa thủ công trong DB / S3 (không có chức năng gỡ trên UI) |
| RISK-008 | Timeout LLM (60 s × tối đa 3 lần gọi) làm hỏng NFR-020 (≤ 30 s); Nginx cắt ở 90 s nên UI có thể nhận lỗi 504 thay vì `ai_unavailable` | 4 | 3 | 12 | PERF-004 sớm (23/11); TL xem lại `llm_timeout_s`, `max_retries` | PO chấp nhận lệch và cập nhật NFR-020; UI xử lý 504 như lỗi mạng (thông điệp "Hệ thống đang bận") |
| RISK-009 | IT không cấp được dải IP / VPN → SEC-001 không thực hiện được | 2 | 5 | 10 | Xin trước 30/10 | Bắt buộc thêm ALB OIDC hoặc Basic Auth (0,5–1 ngày) và bổ sung test xác thực trước go-live |
| RISK-010 | Chi phí Claude khi chạy eval nhiều lần | 2 | 2 | 4 | Hạn mức trong Anthropic Console | Giảm tần suất eval xuống chỉ khi có thay đổi |
| RISK-011 | Thiếu người QA chuyên trách | 3 | 3 | 9 | BE1 kiêm QA; chấm eval do BD | Ưu tiên các mục bắt buộc ở §7.2; mục P1 làm khi còn thời gian |
| RISK-012 | `User_Stories.md`, `SAD.md` chưa cập nhật v0.4 khiến người kiểm thử áp nhầm tiêu chí (ví dụ trích dẫn, streaming) | 3 | 2 | 6 | §5 liệt kê rõ phần không kiểm thử | Khi mâu thuẫn, áp dụng `Implement_plan.md` v0.4 và `tasks/` |

---

## 16. Phê duyệt (IEEE 829 §5.16)

Việc ký dưới đây xác nhận đồng ý với phạm vi, cách tiếp cận, tiêu chí đạt / không đạt và lịch của kế hoạch kiểm thử này.

| Vai trò | Họ tên | Quyết định | Ngày | Ký |
|---|---|---|---|---|
| Product Owner | | ☐ Duyệt ☐ Duyệt có điều kiện ☐ Không duyệt | | |
| Tech lead | | ☐ Duyệt ☐ Duyệt có điều kiện ☐ Không duyệt | | |
| QA lead | | ☐ Duyệt ☐ Duyệt có điều kiện ☐ Không duyệt | | |
| Quản lý | | ☐ Duyệt ☐ Duyệt có điều kiện ☐ Không duyệt | | |
| Đại diện BD | | ☐ Duyệt ☐ Duyệt có điều kiện ☐ Không duyệt | | |

**Điều kiện kèm theo (nếu có):** __________

---

## Phụ lục A. Ma trận truy vết yêu cầu → test case

| Yêu cầu | Ưu tiên | Unit | Integration / API | E2E / UAT | Phi chức năng / khác | Trạng thái hiện tại |
|---|---|---|---|---|---|---|
| US-005 / BR-001 | P0 | UT-023 | INT-001, 002, 003 | E2E-001, 003; UAT-001 | PERF-003 | ✅ (E2E 🆕) |
| AC-US-005-5 | P0 | UT-023 | INT-004 | E2E-003 | — | ✅ |
| NFR-006 / EC-14 | P1 | — | INT-006 | — | — | ✅ |
| EC-08 (rút gọn) | P1 | — | INT-005 | — | — | ✅ |
| US-007 / FR-007 | P0 | UT-006, 007, 023 | INT-004, 007 | E2E-001, 002; UAT-002 | UT-027 | ✅ (E2E 🆕) |
| US-006 / FR-006 | P0 | — | INT-001, 011 | E2E-001; UAT-001 | — | 🖐 → cần E2E-001 |
| NFR-003 | P1 | — | — | — | PERF-001 | ⏳ |
| ADR-006 | P0 | UT-001..004 | INT-001 | — | — | ✅ |
| ADR-010 | P0 | — | INT-009, 010 | — | OPS-007 | ✅ |
| NFR-021 | P0 | UT-010 | INT-007, 008 | E2E-002 | — | ✅ |
| REQ-VN-01 | P0 | UT-005 | — | UAT-001 | — | ✅ |
| REQ-FN-01 | P1 | UT-009 | — | — | SEC-005 | ✅ |
| US-008 / BR-002 | P0 | — | INT-013 | UAT-003 | — | ✅ (embedding thật 🖐) |
| AC-US-008-4 / EC-01 | P0 | UT-014 | INT-017 | E2E-004 | — | ✅ (E2E 🆕) |
| US-011 / BR-006 | P0 | UT-011, 019 | INT-014, 022 | E2E-005; UAT-003 | EVAL-001 | ✅ logic · ⏳ Claude thật |
| AC-US-011-3, 4 / EC-12 | P0 | UT-012, 013, 024 | INT-015, 016 | E2E-006 | — | ✅ |
| AC-US-011-8 / EC-06 | P0 | UT-015, 017, 018 | INT-018, 019 | E2E-007 | OPS-008 | ✅ (E2E 🆕) |
| NFR-020 | P1 | — | — | — | PERF-004 | ⏳ (dự kiến lệch, RISK-008) |
| BRU-001 / US-014 | P0 | UT-016, 020 | — | UAT-004 | EVAL-002, 003 | ✅ cấu hình · ⏳ hành vi thật |
| US-015 | P0 | UT-016, 026 | INT-022 | E2E-005; UAT-003 | EVAL-004; UI-002 | ✅ giao diện · ⏳ câu trả lời |
| UXC-09 | P0 | UT-025 | — | E2E-008 | SEC-004 | ✅ (E2E 🆕) |
| PRD §6.2 / CN-06 | P0 | — | INT-014 | — | SEC-006 | ✅ `qa_log` · 🖐 log |
| KR2.1 | P0 | UT-021 | — | UAT-003 | EVAL-001 | ⏳ |
| KR2.3 | P0 | UT-022 | — | UAT-004 | EVAL-002 | ⏳ |
| NFR-001 | P1 | — | — | — | EVAL-005, PERF-002 | ⏳ |
| API-CONTRACT | P0 | UT-008, 026, 027 | INT-016, 020 | — | — | ✅ |
| NFR-010 | P0 | — | — | — | SEC-002 | ⏳ |
| NFR-011 | P0 | — | — | — | SEC-003 | ⏳ |
| SEC-NET | P0 | — | — | UAT-005 | SEC-001 | ⏳ |
| OPS-LOCAL | P1 | — | — | — | OPS-001, 002 | 🖐 |
| OPS-CI | P0 | — | — | — | OPS-003, 004 | ⏳ |
| OPS-DEPLOY | P0 | — | INT-021 | — | OPS-005, 006; REG-006 | ⏳ |

**Độ phủ:** 32/32 yêu cầu trong phạm vi (100%) có ít nhất một test case được thiết kế. Theo trạng thái hiện tại: 20 yêu cầu có test tự động đang pass (✅, kể cả ✅ một phần), 2 chỉ kiểm thủ công (🖐), 10 chưa kiểm chứng (⏳). Phần lớn yêu cầu ⏳ cần khóa API, golden set hoặc hạ tầng AWS.

---

## Phụ lục B. Đối chiếu checklist IEEE 829

Đối chiếu với `docs/Test_Plan_IEEE_829_Checklist.xlsx`.

| Hạng mục checklist | Mục trong tài liệu | Trạng thái |
|---|---|---|
| Test Plan Identifier | §1 | Đáp ứng |
| Introduction | §2 | Đáp ứng |
| Test Items | §3 | Đáp ứng |
| Features to be Tested | §4 | Đáp ứng |
| Features Not to be Tested | §5 | Đáp ứng |
| Testing Approach | §6.1, §6.3 | Đáp ứng |
| Automation vs Manual | §6.2 | Đáp ứng |
| Item Pass/Fail Criteria | §7 | Đáp ứng |
| Suspension Criteria | §8 | Đáp ứng |
| Resumption Requirements | §8 | Đáp ứng |
| Environmental Needs | §11 | Đáp ứng |
| Responsibilities | §12 | Đáp ứng một phần — còn người [TBD] |
| Staffing & Training Needs | §13 | Đáp ứng |
| Testing Tasks | §10 | Đáp ứng |
| Test Deliverables | §9 | Đáp ứng |
| Schedule | §14 | Đáp ứng |
| Risks & Contingencies | §15 | Đáp ứng |
| Approvals | §16 | Đáp ứng — chờ ký |
