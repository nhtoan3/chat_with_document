# Ma trận truy vết — MVP v0.4 (yêu cầu → task → code → test)

> Cập nhật: 31/10/2026 · Phạm vi: `Implement_plan.md` v0.4 (F1 Xử lý PDF, F2 Hỏi đáp AI)
> Đường dẫn test: `B:` = `backend/tests/`, `F:` = `frontend/src/`

**Ký hiệu trạng thái:**

- ✅ **Kiểm chứng tự động:** có test tự động đang pass.
- 🖐 **Kiểm chứng thủ công:** đã kiểm tra khi chạy thử stack ngày 26/10, chưa có test tự động.
- ⏳ **Chưa kiểm chứng:** cần dữ liệu thật, khóa API hoặc hạ tầng.

## 1. F1 — Xử lý PDF

| Yêu cầu | Nội dung (bản MVP) | Task | Code chính | Test | Trạng thái |
|---|---|---|---|---|---|
| US-005 / BR-001 | Tải lên 1–10 PDF, mỗi tệp ≤ 20 MB | T-009, T-015 | `documents/application/upload.py`, `api/routers/documents.py`, `features/documents/DocumentsPage.tsx` | B: `integration/test_documents.py::test_upload_three_valid_pdfs_then_ingest`, `::test_too_many_files_rejects_whole_batch`; F: `features/documents/validate.test.ts` | ✅ |
| AC-US-005-5 | Một tệp lỗi không chặn các tệp hợp lệ | T-009 | `upload.py` (savepoint từng tệp) | B: `::test_per_file_errors_do_not_block_valid_files` | ✅ |
| NFR-006 | Tối đa 50 tài liệu | T-009 | `upload.py` | B: `::test_collection_full` | ✅ |
| EC-08 (rút gọn) | Trùng tên → `duplicate_name` | T-009 | `upload.py` | B: `::test_duplicate_name` | ✅ |
| US-007 / BR-005 | Báo rõ lý do tệp lỗi: `not_pdf`, `file_too_large`, `encrypted_pdf`, `no_text_layer`, `too_many_pages`, `corrupted` | T-009, T-011, T-015 | `ingestion/pdf_extractor.py`, `upload.py`, `vi.json` | B: `unit/test_pdf_extractor.py::test_rejected_files`, `::test_too_many_pages`, `integration/test_documents.py::test_bad_pdfs_fail_with_code`; F: `validate.test.ts` | ✅ |
| US-006 / FR-006 | Trạng thái xử lý tự cập nhật; toast khi Sẵn sàng | T-014, T-015 | `api/routers/documents.py` (GET), `features/documents/useDocuments.ts` | Chạy thử bằng Playwright + Chrome: tệp mới chuyển Sẵn sàng, toast hiện | 🖐 |
| US-006 / NFR-003 | PDF 50 trang Sẵn sàng ≤ 60 s | T-013 | `worker/ingest.py` | Đo local: 1–2 trang mất 3–4 s/tệp (TEI giả lập x86); **chưa đo với PDF 50 trang trên AWS** | ⏳ |
| ADR-006 | Chunk theo trang, ~500 token, chồng lấp | T-012 | `ingestion/chunker.py` | B: `unit/test_chunker.py` (4 test) | ✅ |
| ADR-010 | Hàng đợi PostgreSQL: không lấy trùng việc, thu hồi việc treo | T-010 | `documents/adapters/job_queue.py` | B: `::test_two_workers_never_claim_the_same_job`, `::test_stale_running_job_is_reclaimed` | ✅ |
| NFR-021 | Lỗi tạm thời thử lại 3 lần (10 s / 40 s / 160 s) rồi `transient_exhausted` | T-010, T-013 | `job_queue.py`, `worker/ingest.py` | B: `::test_transient_errors_retry_then_give_up`, `unit/test_errors_and_upload_helpers.py::test_retry_backoff` | ✅ |
| — | Văn bản tiếng Việt giữ đúng dấu (NFC) | T-011 | `pdf_extractor.py` | B: `unit/test_pdf_extractor.py::test_text_pdf_keeps_pages_and_vietnamese` | ✅ |
| — | Tên tệp an toàn (bỏ đường dẫn, ≤ 255 ký tự) | T-009 | `upload.py::normalize_filename` | B: `unit/test_errors_and_upload_helpers.py::test_normalize_filename_strips_paths_and_limits_length` | ✅ |

## 2. F2 — Hỏi đáp AI

| Yêu cầu | Nội dung (bản MVP) | Task | Code chính | Test | Trạng thái |
|---|---|---|---|---|---|
| US-008 / BR-002 | Chỉ dùng tài liệu Sẵn sàng làm nguồn | T-017 | `qa/adapters/pg_retrieval.py` | B: `integration/test_ask.py::test_retrieval_ranks_relevant_chunk_and_skips_unready` | ✅ |
| US-008 | Truy xuất đúng đoạn với embedding thật (bge-m3) | T-017 | `pg_retrieval.py`, `qa/adapters/tei_embedding.py` | Chạy thử 26/10: câu về phạt → đúng trang 2 hợp đồng (độ tương đồng 0,74); câu không liên quan ~0,25 | 🖐 |
| US-011 / BR-006 | Hỏi bằng ngôn ngữ tự nhiên, nhận câu trả lời | T-019, T-020, T-021 | `qa/application/ask.py`, `api/routers/ask.py`, `features/ask/AskPage.tsx` | B: `unit/test_ask_usecase.py::test_ok_outcome`, `integration/test_ask.py::test_ask_returns_answer_and_logs_without_content` (LLM giả lập) | ✅ (logic) · ⏳ (Claude thật) |
| AC-US-011-3, 4 | Câu hỏi 1–2000 ký tự | T-020, T-021 | `ask.py::validate_question`, `features/ask/validate.ts` | B: `unit/test_ask_usecase.py::test_invalid_question`, `::test_question_is_stripped_and_2000_chars_allowed`, `integration/test_ask.py::test_invalid_question`; F: `features/ask/validate.test.ts` | ✅ |
| AC-US-008-4 | Chưa có tài liệu Sẵn sàng → khóa ô hỏi / 409 `no_documents` | T-020, T-021 | `ask.py`, `AskPage.tsx` | B: `unit/test_ask_usecase.py::test_no_ready_documents_does_not_call_embedder`, `integration/test_ask.py::test_no_ready_documents` | ✅ |
| AC-US-011-8 | AI lỗi → 503 `ai_unavailable`, có nút Hỏi lại | T-019, T-020, T-021 | `anthropic_llm.py`, `ask.py`, `AskPage.tsx` | B: `unit/test_anthropic_adapter.py::test_failures_map_to_llm_unavailable`, `integration/test_ask.py::test_llm_failure_is_503_and_logged`, `unit/test_ask_usecase.py::test_external_failure_is_error_outcome` | ✅ |
| BRU-001 / US-014 (rút gọn) | Chỉ trả lời từ tài liệu; không có thông tin → câu "không tìm thấy" (**chỉ bằng prompt**) | T-018, T-019 | `qa/prompts.py`, `anthropic_llm.py` (refusal → câu không tìm thấy) | B: `unit/test_ask_usecase.py::test_prompt_contains_required_rules_and_context_format`, `unit/test_anthropic_adapter.py::test_refusal_returns_not_found_answer`; golden set câu `negative` | ✅ (cấu hình) · ⏳ (hành vi thật) |
| US-015 | Trả lời tiếng Việt; giao diện tiếng Việt | T-007, T-018 | `prompts.py`, `shared/i18n/vi.json` | F: `shared/api/client.test.ts` (thông điệp lỗi tiếng Việt) | ✅ (giao diện) · ⏳ (câu trả lời) |
| UXC-09 | Câu trả lời render an toàn (chống XSS) | T-021 | `features/ask/markdown.ts` | F: `features/ask/markdown.test.ts` (3 test) | ✅ |
| PRD §6.2 | Đo sử dụng không lưu nội dung (`qa_log`) | T-004, T-020 | `routers/ask.py::_log`, migration `0001_init` | B: `integration/test_ask.py::test_ask_returns_answer_and_logs_without_content` (kiểm tra đúng tập cột) | ✅ |
| KR2.1 | ≥ 80% câu có đáp án được trả lời đúng | T-008, T-023 | `tests/eval/run_eval.py`, `score.py` | B: `unit/test_eval_score.py` (script chấm điểm); **chưa có golden set thật và khóa API** | ⏳ |
| KR2.3 | ≥ 90% câu không có đáp án → "không tìm thấy" | T-008, T-023 | như trên | như trên | ⏳ |
| NFR-001 | p90 thời gian trả lời ≤ 15 s (MVP chấp nhận 10–20 s, không streaming) | T-020, T-023 | `qa_log.latency_ms`, `score.py` | Chưa đo với Claude thật | ⏳ |

## 3. Nền tảng & phi chức năng

| Yêu cầu | Nội dung | Task | Code / cấu hình | Kiểm chứng | Trạng thái |
|---|---|---|---|---|---|
| API contract | Lỗi dạng problem+json có `code` | T-005 | `platform/errors.py` | B: `unit/test_errors_and_upload_helpers.py::test_app_error_is_problem_json`; F: `shared/api/client.test.ts` | ✅ |
| CN-06 | Không log nội dung tài liệu / câu hỏi | T-005, T-019 | `platform/logging.py`, `anthropic_llm.py` | Rà soát code; log mẫu lúc chạy thử chỉ có số liệu | 🖐 |
| NFR-010, 011 | TLS, SSE-KMS cho S3, RDS mã hóa | T-006 | `platform/storage.py` (`S3_USE_KMS`), `infra/README.md` | Chưa dựng AWS | ⏳ |
| Thay cho đăng nhập | Chỉ truy cập từ IP / VPN công ty | T-006 | `infra/README.md` (security group ALB) | Chưa dựng AWS | ⏳ |
| Môi trường local | `make dev` chạy đủ stack | T-002 | `docker-compose.yml` | Chạy thử 26/10: đủ dịch vụ healthy sau khi sửa TEI (hết bộ nhớ) và S3Mock (mất dữ liệu) | 🖐 |
| CI | Lint + test mỗi PR; build image trên `main` | T-003 | `.github/workflows/ci.yml` | **Chưa chạy lần nào trên GitHub**; job build cần secret `AWS_DEPLOY_ROLE_ARN` | ⏳ |
| Deploy | Deploy / rollback ≤ 10 phút | T-006 | `infra/deploy.sh`, `rollback.sh` | Chưa dựng AWS | ⏳ |
| Go-live | UAT, hướng dẫn sử dụng | T-024 | `docs/implement/evidence/UAT.md`, `Huong_dan_su_dung.md` | Mới là mẫu | ⏳ |

## 4. Tổng hợp

| Nhóm | ✅ Tự động | 🖐 Thủ công | ⏳ Chưa kiểm chứng |
|---|---|---|---|
| F1 Xử lý PDF (12 dòng) | 10 | 1 | 1 |
| F2 Hỏi đáp AI (13 dòng) | 6 (+ 3 dòng ✅/⏳: logic đã test, chưa thử với Claude thật) | 1 | 3 |
| Nền tảng (8 dòng) | 1 | 2 | 5 |

**Số test:** backend 50 (unit + tích hợp trên PostgreSQL + pgvector thật) · frontend 15 (vitest). Chưa có test E2E Playwright tự động.

**Để chuyển các dòng ⏳ sang ✅:**

1. Có `ANTHROPIC_API_KEY` (sau quyết định OQ-008) → chạy hỏi đáp thật.
2. Đội BD giao golden set → T-023 đo KR2.1, KR2.3, NFR-001.
3. Dựng AWS (T-006) → kiểm tra TLS, KMS, giới hạn IP, deploy / rollback, đo NFR-003 với PDF 50 trang.
4. Đẩy một PR để CI chạy lần đầu.

## 5. Yêu cầu đã lược bỏ ở v0.4 (không truy vết)

US-001, 002, 003, 004, 023 (đăng nhập, phân quyền) · US-010 (gỡ tài liệu trên giao diện) · US-012 (tinh chỉnh đa nguồn riêng) · US-013, 017 (trích dẫn, mở PDF tại trang) · US-014 (kiểm tra "không tìm thấy" phía server) · US-016, 025 (streaming, dừng) · US-018..022 (đánh giá, hội thoại, lịch sử, số liệu). Xem `Implement_plan.md` §1.
