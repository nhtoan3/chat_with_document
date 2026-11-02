# Thiết kế API — "Chat với tài liệu" (MVP v0.4)

> Version 0.1 · Trạng thái: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Cấu trúc theo `sdlc/design/apiDesign_prompt.md` (IEEE 1016-2009), rút gọn cho API nhỏ. Bản prompt trong repo kết thúc ở §3.1 Composition View, nên §3.2 trở đi của tài liệu này là phần mô tả giao diện theo code.
> **Nguồn sự thật là code:** `backend/app/api/`, `backend/app/platform/errors.py`, `backend/app/modules/documents/application/upload.py`, `frontend/src/shared/api/`.

## 1. Ngữ cảnh

### 1.1 Định danh

| Thuộc tính | Giá trị |
|---|---|
| Hệ thống | Chat với tài liệu (`info.version` trong code: `0.1.0`) |
| Phạm vi | Plan v0.4: F1 Xử lý PDF, F2 Hỏi đáp AI |
| Chủ tài liệu | [TBD: OQ-001] |

### 1.2 Phạm vi và ranh giới

| Mục | Mô tả |
|---|---|
| Tài nguyên nghiệp vụ | 2 nhóm: `/api/v1/documents` (GET, POST), `/api/v1/ask` (POST) |
| Endpoint vận hành | `/healthz`; `/api/v1/docs` (Swagger UI), `/api/v1/openapi.json` |
| Bên gọi API | Chỉ SPA nội bộ (`frontend/src/shared/api/`), cùng origin qua Nginx |
| Hệ thống ngoài | S3, TEI (`bge-m3`), Anthropic Messages API. Việc gửi dữ liệu tới Anthropic chờ OQ-008 ([ADR-005](ADR-005-llm-provider.md)) |
| Ranh giới tin cậy | ALB chỉ cho phép IP / VPN công ty; API không xác thực ([ADR-007](ADR-007-session-authentication.md)) |
| Triển khai | Một môi trường AWS `ap-southeast-1` ([ADR-009](ADR-009-docker-compose-single-ec2.md)) |

Không có trong v0.4 so với SAD §2.4: `/auth/*`, `/me`, `/conversations/*`, `/messages/*`, `/events`, `/admin/*`, `/documents/{id}/file`, `DELETE /documents/{id}`, `/documents/{id}/replace`, `/readyz`, SSE, Citations.

### 1.3 Ràng buộc

| Ràng buộc | Giá trị mặc định | Nguồn |
|---|---|---|
| Số tệp mỗi lần tải | 1–10 | `platform/config.py:27` |
| Dung lượng mỗi tệp | ≤ 20 MB | `config.py:26` |
| Số tài liệu tối đa | 50, tính cả tài liệu `failed` | `config.py:29`, `adapters/sql_repo.py:11-12` |
| Số trang tối đa | 300 (kiểm tra ở worker) | `config.py:28` |
| Độ dài câu hỏi | 1–2000 ký tự, sau khi `strip()` | `modules/qa/application/ask.py:14,39-43` |
| Số chunk truy xuất | 12 | `config.py:25` |

Các giá trị đọc từ biến môi trường nên có thể khác theo môi trường.

## 2. Bên liên quan và mối quan tâm

| Bên liên quan | Mối quan tâm với API | Hiện trạng |
|---|---|---|
| Đội BD (STK-002), qua SPA | Thông điệp lỗi rõ ràng, thời gian chờ chấp nhận được | Mã lỗi ánh xạ sang `vi.json`; xem §5, §6 |
| Bảo mật / IT (STK-005) | Tài liệu không bị lộ | Chỉ giới hạn mạng; OQ-008 đang mở |
| Đội phát triển (STK-004) | Hợp đồng kiểm chứng được | Schema tự sinh chưa mô tả response (§5) |

**Thuộc tính chất lượng:**

| Thuộc tính | Kịch bản | Trạng thái |
|---|---|---|
| Độ trễ `/ask` | p90 ≤ 15 s ⚑; v0.4 chấp nhận 10–20 s | Chưa đo với Claude thật (`docs/01-intake/intent.md` §5) |
| Xử lý tài liệu | PDF 50 trang Sẵn sàng ≤ 60 s ⚑ | Chưa đo trên AWS (`docs/05-development/traceability.md`) |
| Khả dụng | ≥ 95% ⚑ giờ hành chính (TC-08) | Chưa đo |
| Thông lượng | [TBD: OQ-005] | — |

**Ma trận ràng buộc thiết kế:**

| Ràng buộc | v0.4 | Ghi chú |
|---|---|---|
| Đặc tả | OpenAPI 3.1 tự sinh + §4 | |
| Xác thực | **Không có** | Giới hạn IP / VPN ở ALB |
| CSRF | Không có | SAD yêu cầu `X-CSRF-Token`; chưa áp dụng |
| CORS | Không cấu hình | SPA cùng origin |
| Rate limit | **Không có** | [ADR-011](ADR-011-mvp-feature-reductions.md) |
| Phân trang | **Không có** | T-014; `limit` trong response là giới hạn bộ tài liệu, không phải cỡ trang |
| Phiên bản | URI `/api/v1` | |
| Lỗi | RFC 9457 `application/problem+json` | Có ngoại lệ, xem §3.3 |
| Idempotency | **Không có** `Idempotency-Key` | Gửi lại tệp đã tải thành công nhận `duplicate_name` |
| Truy vết | `X-Request-ID` | Nhận từ request hoặc tự sinh; response 500 không mang header này |

## 3. Design views

### 3.1 Composition view

| Lớp | Thành phần |
|---|---|
| Biên | ALB → Nginx (`frontend/nginx.conf`): `/api/`, `/healthz` → `api:8000` |
| Router | `api/routers/documents.py`, `api/routers/ask.py`; `/healthz` trong `api/main.py` |
| Xử lý chung | `platform/errors.py`, `platform/logging.py`, `api/deps.py` |
| Use case | `documents/application/upload.py`, `qa/application/ask.py` |
| Adapter | `documents/adapters/sql_repo.py`, `qa/adapters/{pg_retrieval,tei_embedding,anthropic_llm}.py`, `platform/storage.py` |

### 3.2 Interface view

| Endpoint | Hành vi | Thành công |
|---|---|---|
| `POST /api/v1/documents` | Kiểm tra cả lô, rồi xử lý từng tệp độc lập. Tệp hợp lệ được lưu S3 và xếp hàng xử lý | **202**, kể cả khi mọi tệp đều lỗi; lỗi từng tệp nằm trong `items[].error_code` |
| `GET /api/v1/documents` | Toàn bộ tài liệu, `uploaded_at DESC`; `counts.processing` = `queued` + `processing` | 200 |
| `POST /api/v1/ask` | Kiểm tra câu hỏi → kiểm tra có tài liệu `ready` → embed → truy xuất → LLM → ghi `qa_log` | 200 `{answer, latency_ms}`; `answer` là Markdown |
| `GET /healthz` | Trả cố định, không kiểm tra DB / TEI / S3 | 200 `{"status":"ok"}` |

`answer` có thể là câu `"Không tìm thấy thông tin này trong tài liệu."` với HTTP 200: API không có trường `not_found`.

### 3.3 Lỗi

Thân lỗi: `{type: "about:blank", title, status, code, detail?}`. `title` là tiếng Anh; SPA hiển thị theo `code` qua `vi.json`.

**Mã lỗi trả ở cấp HTTP:**

| `code` | HTTP | Endpoint | Khi nào |
|---|---|---|---|
| `too_many_files` | 422 | POST documents | 0 tệp hoặc > 10 tệp |
| `collection_full` | 409 | POST documents | Số tài liệu hiện có + số tệp gửi lên > 50 |
| `question_invalid` | 422 | POST ask | Câu hỏi rỗng / quá dài; body sai định dạng |
| `question_invalid` | 422 | POST documents | **Bất thường:** trường `files` không phải tệp (§6) |
| `no_documents` | 409 | POST ask | Không có tài liệu `ready` |
| `ai_unavailable` | 503 | POST ask | Lỗi TEI hoặc LLM, kể cả thiếu API key |
| `storage_error` | 502 | POST documents | Chỉ khi DB lỗi và bước xóa object bù trừ cũng lỗi (`upload.py:112`) |
| `internal_error` | 500 | Mọi endpoint | Lỗi không xử lý, ví dụ DB lỗi |

**Mã lỗi từng tệp** trong `202 items[].error_code` (`upload.py`): `not_pdf`, `file_too_large`, `duplicate_name`, `storage_error`.

**Mã lỗi xử lý nền** trong `GET documents items[].error_code`: `encrypted_pdf`, `no_text_layer`, `too_many_pages`, `corrupted`, `transient_exhausted`.

**Response lỗi không theo problem+json:**

| Trường hợp | Thân | Nguồn |
|---|---|---|
| 404 đường dẫn lạ, 405 sai method | `{"detail": "Not Found"}`, `{"detail": "Method Not Allowed"}` (`application/json`) | Starlette mặc định; chưa có handler |
| 413, 502, 504 do Nginx / ALB | Không phải JSON của API | `frontend/nginx.conf`; SPA quy mã lỗi ≥ 500 không parse được về `internal_error`, còn lại về `unknown` (`shared/api/client.ts:22-34`) |

### 3.4 Thời gian chờ

| Tầng | Giá trị | Nguồn |
|---|---|---|
| TEI (từ API) | 10 s | `api/deps.py:19` |
| LLM | 60 s mỗi lần, `max_retries=2` | `config.py:22`, `anthropic_llm.py:14` |
| Nginx → API | 90 s | `frontend/nginx.conf` |
| ALB idle | 120 s | `infra/README.md` §2 |

Nếu LLM timeout rồi retry, tổng thời gian có thể vượt 90 s của Nginx. Khi đó SPA sẽ nhận 504 và hiển thị `internal_error` thay vì 503 `ai_unavailable`. Đây là suy ra từ cấu hình, chưa chạy thử. `api/routers/ask.py:43-52` cũng giữ một transaction DB trong suốt lời gọi LLM.

## 4. Đặc tả OpenAPI 3.1

Đặc tả viết tay theo hành vi code, không phải bản tự sinh. `/healthz` được thêm vào đây dù code đặt `include_in_schema=False`.

```yaml
openapi: 3.1.0
info:
  title: Chat với tài liệu — API
  version: 0.1.0
  description: >
    MVP v0.4. Không xác thực ở tầng ứng dụng; truy cập được giới hạn theo IP / VPN tại ALB.
servers:
  - url: /
security: []
tags:
  - name: documents
  - name: ask
  - name: ops
paths:
  /healthz:
    get:
      tags: [ops]
      summary: Kiểm tra tiến trình API còn chạy
      description: Trả cố định; không kiểm tra DB, TEI, S3. Không có trong schema tự sinh.
      operationId: healthz
      responses:
        '200':
          description: API đang chạy
          content:
            application/json:
              schema:
                type: object
                required: [status]
                properties:
                  status:
                    type: string
                    const: ok
  /api/v1/documents:
    get:
      tags: [documents]
      summary: Liệt kê toàn bộ tài liệu
      description: Sắp xếp uploaded_at giảm dần. Không phân trang, không lọc.
      operationId: list_documents
      responses:
        '200':
          description: Danh sách tài liệu
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/DocumentsResponse'
        '500':
          $ref: '#/components/responses/InternalError'
    post:
      tags: [documents]
      summary: Tải lên 1–10 tệp PDF
      description: >
        Kiểm tra cả lô rồi xử lý từng tệp độc lập. Trả 202 kể cả khi mọi tệp đều lỗi.
        Không gửi tệp nào thì nhận 422 too_many_files.
      operationId: upload_documents
      requestBody:
        required: false
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                files:
                  type: array
                  minItems: 1
                  maxItems: 10
                  items:
                    type: string
                    contentMediaType: application/pdf
                    description: Tối đa 20 MB; 5 byte đầu phải là %PDF-
      responses:
        '202':
          description: Đã xử lý lô; xem kết quả từng tệp trong items
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UploadResponse'
              example:
                items:
                  - filename: a.pdf
                    document_id: 3fa85f64-5717-4562-b3fc-2c963f66afa6
                    status: queued
                  - filename: b.docx
                    error_code: not_pdf
        '409':
          description: collection_full
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
        '422':
          description: too_many_files; hoặc question_invalid khi trường files không phải tệp
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
        '500':
          $ref: '#/components/responses/InternalError'
        '502':
          description: storage_error; chỉ khi DB lỗi và xóa object bù trừ cũng lỗi
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
  /api/v1/ask:
    post:
      tags: [ask]
      summary: Hỏi đáp dựa trên các tài liệu ready
      operationId: ask_question
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/AskRequest'
      responses:
        '200':
          description: >
            Câu trả lời. Khi tài liệu không có thông tin, answer là câu "không tìm thấy"
            và HTTP vẫn là 200.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AskResponse'
        '409':
          description: no_documents
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
        '422':
          description: question_invalid
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
        '500':
          $ref: '#/components/responses/InternalError'
        '503':
          description: ai_unavailable; lỗi TEI hoặc LLM
          content:
            application/problem+json:
              schema:
                $ref: '#/components/schemas/Problem'
components:
  responses:
    InternalError:
      description: internal_error
      content:
        application/problem+json:
          schema:
            $ref: '#/components/schemas/Problem'
  schemas:
    AskRequest:
      type: object
      required: [question]
      properties:
        question:
          type: string
          minLength: 1
          maxLength: 2000
          description: Độ dài được kiểm tra sau khi strip().
    AskResponse:
      type: object
      required: [answer, latency_ms]
      properties:
        answer:
          type: string
          description: Markdown; client phải render an toàn.
        latency_ms:
          type: integer
    DocumentStatus:
      type: string
      enum: [queued, processing, ready, failed]
    DocumentItem:
      type: object
      required: [id, filename, pages, uploaded_at, status, error_code]
      properties:
        id:
          type: string
          format: uuid
        filename:
          type: string
        pages:
          type: [integer, 'null']
        uploaded_at:
          type: string
          format: date-time
        status:
          $ref: '#/components/schemas/DocumentStatus'
        error_code:
          type: [string, 'null']
          enum: [encrypted_pdf, no_text_layer, too_many_pages, corrupted, transient_exhausted, null]
    DocumentCounts:
      type: object
      required: [ready, processing, failed, total]
      properties:
        ready:
          type: integer
        processing:
          type: integer
          description: Tổng số tài liệu queued và processing.
        failed:
          type: integer
        total:
          type: integer
    DocumentsResponse:
      type: object
      required: [items, counts, limit]
      properties:
        items:
          type: array
          items:
            $ref: '#/components/schemas/DocumentItem'
        counts:
          $ref: '#/components/schemas/DocumentCounts'
        limit:
          type: integer
          description: Số tài liệu tối đa của bộ tài liệu, không phải cỡ trang.
    UploadAccepted:
      type: object
      required: [filename, document_id, status]
      properties:
        filename:
          type: string
        document_id:
          type: string
          format: uuid
        status:
          type: string
          const: queued
    UploadRejected:
      type: object
      required: [filename, error_code]
      properties:
        filename:
          type: string
        error_code:
          type: string
          enum: [not_pdf, file_too_large, duplicate_name, storage_error]
    UploadResponse:
      type: object
      required: [items]
      properties:
        items:
          type: array
          items:
            oneOf:
              - $ref: '#/components/schemas/UploadAccepted'
              - $ref: '#/components/schemas/UploadRejected'
    Problem:
      type: object
      description: RFC 9457 problem details.
      required: [type, title, status, code]
      properties:
        type:
          type: string
          const: about:blank
        title:
          type: string
        status:
          type: integer
        code:
          type: string
          enum:
            - too_many_files
            - collection_full
            - question_invalid
            - no_documents
            - ai_unavailable
            - storage_error
            - internal_error
        detail:
          type: string
```

## 5. Khác biệt giữa code và schema tự sinh

Đối chiếu với `app.openapi()` chạy ngày 2026-11-02.

| # | Schema tự sinh | Hành vi thực tế | Nguồn |
|---|---|---|---|
| 1 | `POST /documents` 202: `schema: {}` | `{items: [...]}` như §4 | Router trả `JSONResponse` (`routers/documents.py:22`) |
| 2 | `GET /documents` 200: object tùy ý | `{items, counts, limit}` | Router khai `-> dict` (`routers/documents.py:26`) |
| 3 | `POST /ask` 200: object tùy ý | `{answer, latency_ms}` | Router khai `-> dict` (`routers/ask.py:41`) |
| 4 | 422 là `HTTPValidationError` (`detail` dạng mảng) | Không bao giờ trả dạng này: problem+json, `detail` là chuỗi | Handler `errors.py:52-55` |
| 5 | Không khai 409, 500, 502, 503 | Có trả các mã này | `errors.py:11-23` |
| 6 | `AskRequest.question` chỉ là `string` | Giới hạn 1–2000 ở use case; vi phạm vẫn trả 422 | `qa/application/ask.py:39-43` |
| 7 | `files` không có giới hạn số lượng; `application/octet-stream` | 1–10 tệp, kiểm tra magic bytes `%PDF-` | `upload.py:22,57,75` |
| 8 | Không có `/healthz` | Có | `include_in_schema=False`, `api/main.py:22` |

Kiểu thật hiện chỉ được khai báo phía client ở `frontend/src/shared/api/{documents,ask}.ts`; các kiểu này khớp với §4, trừ việc `error_code` là `string` tự do. Để schema tự sinh khớp §4, cần `response_model` và `responses` trong router; thay đổi này chưa được thực hiện.

## 6. Điểm cần xử lý

| # | Vấn đề | Nguồn |
|---|---|---|
| 1 | `POST /documents` với `files` là trường văn bản trả `question_invalid` ("Question is empty or too long"), vì handler coi mọi lỗi validation là của `/ask`. Comment "the only JSON body" đúng, nhưng handler cũng bắt lỗi multipart | `platform/errors.py:52-55` |
| 2 | `not_pdf` (422), `file_too_large` (413), `duplicate_name` (409) có HTTP status trong `ERRORS` nhưng không bao giờ được trả ở cấp HTTP | `errors.py:12-15`; `upload.py` |
| 3 | `not_found` có trong `ERRORS` nhưng không route nào dùng, không có trong `vi.json` và `errors.ts`. 404 thực tế là `{"detail":"Not Found"}` | `errors.py:21`; `shared/api/errors.ts:4-9` |
| 4 | Docstring nói mọi mã frontend có thể nhận đều nằm trong `ERRORS`, nhưng 5 mã xử lý nền không nằm trong đó | `errors.py:3-4`; `ingestion/pdf_extractor.py:23` |
| 5 | Hai request cùng tên tệp đồng thời: vi phạm `UNIQUE (filename)` được báo là `storage_error`, không phải `duplicate_name` | `upload.py:106-114` |
| 6 | Tổng thời gian chờ LLM có thể vượt timeout Nginx (§3.4) | `anthropic_llm.py:14`; `frontend/nginx.conf` |
| 7 | `AiUnavailable` được khai báo và docstring có nhắc tới, nhưng không được dùng; router raise `AppError` trực tiếp | `qa/application/ask.py:25-26,55-57`; `routers/ask.py:59-60` |

## 7. Truy vết

| Yêu cầu | Endpoint | Task |
|---|---|---|
| US-005, US-007 | `POST /api/v1/documents` | T-009 |
| US-006 | `GET /api/v1/documents` | T-014 |
| US-008, US-011, US-015 | `POST /api/v1/ask` | T-020 |

Trạng thái kiểm thử từng yêu cầu xem `docs/05-development/traceability.md`.
