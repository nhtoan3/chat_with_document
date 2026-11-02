# Báo cáo kết quả kiểm thử (Test Report) — Chat với tài liệu (MVP v0.4)

> **Trạng thái:** Draft · **Ngày:** 2026-11-02 · **Commit:** `c02cc729bab8fe1537e398add2740fe7a26bac51` (`c02cc72`) · **Giai đoạn:** Phase 7 — Verify · **Kế hoạch:** [Test_Plan.md](Test_Plan.md) (TP-CWD-001 v0.2) · **Test case:** [test_cases/README.md](test_cases/README.md)
>
> Báo cáo này không thay thế `Test_Summary_Report.md` (hạn 27/11). Phạm vi là bằng chứng trên **localhost**, chưa có khuyến nghị go / no-go.

## 1. Tóm tắt

**64 Đạt · 5 Không đạt · 8 Bị chặn** trên 77 test case. Có **1 lỗi Critical đề xuất và 3 lỗi Major** trong sản phẩm cần xử lý hoặc PO chấp nhận:

1. **DEF-01:** tải lên tệp > 8 MB thất bại trên stack local vì multipart bị S3Mock từ chối. Chưa kiểm chứng trên S3 thật, đây là việc cần làm đầu tiên.
2. **DEF-02:** AI không phản hồi thì 182,5 s mới báo lỗi, so với mục tiêu ≤ 30 s.
3. **DEF-03:** PDF 50 trang không xử lý được trên máy này vì embed vượt timeout 30 s (TEI giả lập x86).
4. **DEF-04:** thiếu thông điệp tiếng Việt cho mã `not_found`.

Chất lượng trả lời của AI **chưa được đo**: toàn bộ EVAL-001 … 005 và INT-022 bị chặn vì không có `ANTHROPIC_API_KEY`.

| Nhóm | Tổng | ✅ Đạt | ❌ Không đạt | ⛔ Bị chặn |
|---|---|---|---|---|
| Unit test | 27 | 26 | 1 | 0 |
| Integration / API | 22 | 20 | 0 | 2 |
| E2E / hệ thống | 9 | 9 | 0 | 0 |
| Đánh giá chất lượng AI | 5 | 0 | 0 | 5 |
| Hiệu năng | 3 | 0 | 3 | 0 |
| Bảo mật (theo tiêu chí task) | 3 | 3 | 0 | 0 |
| Giao diện | 3 | 2 | 0 | 1 |
| Vận hành | 5 | 4 | 1 | 0 |
| **Tổng** | **77** | **64** | **5** | **8** |

Độ phủ (chi tiết ở [coverage/README.md](coverage/README.md), so với mục tiêu ≥ 70% của quy trình): backend **76%** đạt; frontend **7,11%** (9,87% nếu bỏ `frontend/e2e/`) không đạt.

## 2. Môi trường

| Mục | Giá trị |
|---|---|
| Máy | Darwin 27.0.0 arm64 (Apple Silicon), Docker 29.6.2, 8 CPU, Docker VM 7,75 GiB (hơi dưới mức ≥ 8 GB của test case) |
| Stack | `make dev`: postgres (`pgvector/pgvector:pg16`), s3 (Adobe S3Mock, digest đã ghim), tei (`text-embeddings-inference:cpu-1.7`, `BAAI/bge-m3`, `--max-batch-tokens 2048`, **amd64 chạy giả lập**), api, worker × 2, web |
| Công cụ | Python 3.12.16, pytest 8.4.2, Node 24.18.0, vitest 2.1.9, Playwright 1.64.1 (Chromium, headless) |
| ANTHROPIC_API_KEY | **Không có**: không có `.env`, biến môi trường bị bỏ khi chạy, `len(ANTHROPIC_API_KEY)=0` trong container api |
| Mã nguồn | Commit `c02cc72`. Cây làm việc có thay đổi chưa commit, chỉ trong tài liệu; không có thay đổi trong `backend/`, `frontend/`, `infra/` |
| Thời gian chạy | 68 test case: 02/11/2026 21:34 → 22:13 (UTC+7), tuần tự. E2E-001 … 009: 31/10/2026, kết quả chép từ [E2E-summary.md](../../test_reports/E2E-summary.md), **không chạy lại** |

## 3. Kết quả từng test case

### Unit test

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| UT-001 | Chunker: trang dài được chia trong giới hạn và có chồng lấp | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-001/report.md) |  |
| UT-002 | Chunker: trang ngắn được gộp với trang sau | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-002/report.md) |  |
| UT-003 | Chunker: chunk không trải qua hai trang thường | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-003/report.md) |  |
| UT-004 | Chunker: bỏ trang rỗng, văn bản embed có tiền tố | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-004/report.md) |  |
| UT-005 | Trích xuất PDF giữ trang và dấu tiếng Việt (NFC) | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-005/report.md) |  |
| UT-006 | Trích xuất PDF từ chối tệp mã hóa, scan, hỏng | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-006/report.md) |  |
| UT-007 | Trích xuất PDF từ chối tệp quá 300 trang | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-007/report.md) |  |
| UT-008 | AppError được render thành problem+json | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-008/report.md) |  |
| UT-009 | Chuẩn hóa tên tệp: bỏ đường dẫn, giới hạn độ dài | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-009/report.md) |  |
| UT-010 | Backoff thử lại 10 / 40 / 160 giây | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-010/report.md) |  |
| UT-011 | Use case hỏi đáp: kết quả thành công | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-011/report.md) |  |
| UT-012 | Use case hỏi đáp: câu hỏi không hợp lệ | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-012/report.md) |  |
| UT-013 | Use case hỏi đáp: trim câu hỏi, cho phép đúng 2000 ký tự | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-013/report.md) |  |
| UT-014 | Use case hỏi đáp: không có tài liệu Sẵn sàng thì không gọi embedder | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-014/report.md) |  |
| UT-015 | Use case hỏi đáp: lỗi dịch vụ ngoài thành kết quả lỗi | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-015/report.md) |  |
| UT-016 | Prompt chứa đủ quy tắc bắt buộc và định dạng ngữ cảnh | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-016/report.md) |  |
| UT-017 | Adapter Claude: lỗi API được ánh xạ thành LLM unavailable | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-017/report.md) |  |
| UT-018 | Adapter Claude: TypeError không liên quan không bị nuốt | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-018/report.md) |  |
| UT-019 | Adapter Claude: ghép các text block, bỏ thinking | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-019/report.md) |  |
| UT-020 | Adapter Claude: refusal trả câu "không tìm thấy" | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-020/report.md) |  |
| UT-021 | Chấm điểm eval: tỷ lệ và câu chưa chấm | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-021/report.md) |  |
| UT-022 | Chấm điểm eval: nhận diện câu "không tìm thấy" | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-022/report.md) |  |
| UT-023 | Kiểm tra tệp phía client (số lượng, loại, dung lượng) | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-023/report.md) |  |
| UT-024 | Kiểm tra câu hỏi phía client (rỗng, 2000 / 2001 ký tự) | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-024/report.md) |  |
| UT-025 | Render Markdown an toàn (chống XSS) | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-025/report.md) |  |
| UT-026 | API client: tiền tố, problem+json, lỗi mạng, thông điệp tiếng Việt | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/UT-026/report.md) |  |
| UT-027 | Mọi mã lỗi đều có thông điệp tiếng Việt trong vi.json | P1 | ❌ Không đạt | 02/11 | [report](../../test_reports/UT-027/report.md) | DEF-04 |

### Integration / API

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| INT-001 | Tải lên 3 PDF hợp lệ rồi xử lý tới Sẵn sàng | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-001/report.md) |  |
| INT-002 | Tải 11 tệp: từ chối cả lô | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-002/report.md) |  |
| INT-003 | Tải 0 tệp: trả lỗi too_many_files | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-003/report.md) |  |
| INT-004 | Lô trộn: tệp lỗi không chặn tệp hợp lệ | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-004/report.md) |  |
| INT-005 | Trùng tên tài liệu đã có | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-005/report.md) |  |
| INT-006 | Bộ tài liệu đạt giới hạn 50 | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-006/report.md) |  |
| INT-007 | PDF lỗi được đánh dấu failed với mã tương ứng | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-007/report.md) |  |
| INT-008 | Lỗi tạm thời: thử lại 3 lần rồi transient_exhausted | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-008/report.md) |  |
| INT-009 | Hai worker không lấy trùng một job | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-009/report.md) |  |
| INT-010 | Thu hồi job treo (running quá hạn) | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-010/report.md) |  |
| INT-011 | GET /documents: danh sách, counts, thứ tự | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-011/report.md) |  |
| INT-012 | Lỗi lưu trữ S3 khi tải lên → 502 storage_error | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-012/report.md) | Nhận 202 + item lỗi, không phải 502 (TC-03, cần chốt hợp đồng API) |
| INT-013 | Truy xuất xếp hạng đúng đoạn và bỏ tài liệu chưa Sẵn sàng | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-013/report.md) |  |
| INT-014 | Hỏi đáp thành công và qa_log không chứa nội dung | P0 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/INT-014/report.md) | Bước 1, 5 có kết quả; bước 4 cần Claude thật |
| INT-015 | Câu hỏi rỗng / quá dài → 422 question_invalid | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-015/report.md) |  |
| INT-016 | Body không hợp lệ → 422 question_invalid (problem+json) | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-016/report.md) |  |
| INT-017 | Không có tài liệu Sẵn sàng → 409 no_documents | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-017/report.md) |  |
| INT-018 | LLM lỗi → 503 ai_unavailable và qa_log status error | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-018/report.md) | Dùng chuỗi không hợp lệ `sk-ant-invalid` theo test case |
| INT-019 | TEI lỗi khi hỏi → 503 ai_unavailable | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-019/report.md) |  |
| INT-020 | Lỗi không lường trước → 500 internal_error, không lộ stack trace | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-020/report.md) | Phát hiện DEF-05 ngoài phạm vi test |
| INT-021 | /healthz trả 200 | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/INT-021/report.md) | Kiểm tra `id="root"` bằng script bổ sung (TC-02) |
| INT-022 | Gọi Claude thật với tài liệu mẫu (live) | P1 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/INT-022/report.md) | Thiếu `ANTHROPIC_API_KEY`; chưa có số đo |

### E2E / hệ thống

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| E2E-001 | Tải lên PDF và theo dõi trạng thái tới Sẵn sàng | P0 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-001/report.md) |  |
| E2E-002 | Tệp lỗi sau xử lý hiển thị đúng lý do | P0 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-002/report.md) |  |
| E2E-003 | Kiểm tra tệp phía client (> 10 tệp, > 20 MB) | P1 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-003/report.md) |  |
| E2E-004 | Chưa có tài liệu Sẵn sàng: khóa ô hỏi | P0 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-004/report.md) |  |
| E2E-005 | Hỏi và nhận câu trả lời | P0 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-005/report.md) | API giả lập, chưa chạy với Claude thật |
| E2E-006 | Kiểm tra ô nhập câu hỏi | P1 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-006/report.md) | Xem E2E-F1 |
| E2E-007 | Lỗi AI và nút Hỏi lại | P0 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-007/report.md) | API giả lập |
| E2E-008 | XSS trong câu trả lời không được thực thi | P0 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-008/report.md) | API giả lập |
| E2E-009 | Lịch sử hỏi đáp chỉ giữ trong trang | P2 | ✅ Đạt | 31/10 | [report](../../test_reports/E2E-009/report.md) | API giả lập |

### Đánh giá chất lượng AI

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| EVAL-001 | Tỷ lệ trả lời đúng câu positive ≥ 80% | P0 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/EVAL-001/report.md) | Thiếu `ANTHROPIC_API_KEY`; chưa có số đo |
| EVAL-002 | Tỷ lệ "không tìm thấy" câu negative ≥ 90% | P0 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/EVAL-002/report.md) | Thiếu `ANTHROPIC_API_KEY`; chưa có số đo |
| EVAL-003 | Không bịa ở câu negative | P0 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/EVAL-003/report.md) | Thiếu `ANTHROPIC_API_KEY`; chưa có số đo |
| EVAL-004 | Mọi câu trả lời bằng tiếng Việt | P0 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/EVAL-004/report.md) | Thiếu `ANTHROPIC_API_KEY`; chưa có số đo |
| EVAL-005 | Độ trễ p90 trên golden set | P1 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/EVAL-005/report.md) | Thiếu `ANTHROPIC_API_KEY`; chưa có số đo |

### Hiệu năng

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| PERF-001 | PDF văn bản 50 trang Sẵn sàng ≤ 60 giây | P1 | ❌ Không đạt | 02/11 | [report](../../test_reports/PERF-001/report.md) | DEF-03 (TEI giả lập x86) |
| PERF-003 | Tải lô 10 × 20 MB: RAM api tăng ≤ 100 MB | P1 | ❌ Không đạt | 02/11 | [report](../../test_reports/PERF-003/report.md) | DEF-01; phép đo RAM không có giá trị kết luận |
| PERF-004 | AI không phản hồi: báo lỗi trong ≤ 30 giây | P1 | ❌ Không đạt | 02/11 | [report](../../test_reports/PERF-004/report.md) | DEF-02: 182,5 s so với ≤ 30 s |

### Bảo mật (theo tiêu chí task)

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| SEC-004 | Chống XSS trong câu trả lời | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/SEC-004/report.md) | `/ask` giả lập theo test case |
| SEC-005 | An toàn khi tải tệp (tên tệp, loại tệp, kích thước) | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/SEC-005/report.md) |  |
| SEC-006 | Không log nội dung câu hỏi, câu trả lời, tài liệu | P0 | ✅ Đạt | 02/11 | [report](../../test_reports/SEC-006/report.md) | Chỉ đường lỗi; đường thành công chưa kiểm vì không có khóa |

### Giao diện

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| UI-001 | Giao diện khớp thiết kế HTML (bản tối giản) | P1 | ⛔ Bị chặn | 02/11 | [report](../../test_reports/UI-001/report.md) | Phần tự động đạt; "không có khác biệt Major" cần người xác nhận |
| UI-002 | Không có chuỗi giao diện viết cứng trong TSX | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/UI-002/report.md) |  |
| UI-003 | Badge trạng thái có icon và chữ | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/UI-003/report.md) | Dừng worker để chụp badge chờ, theo ghi chú test case |

### Vận hành

| Mã | Tên | Ưu tiên | Kết luận | Ngày chạy | Báo cáo | Ghi chú |
|---|---|---|---|---|---|---|
| OPS-001 | make dev dựng đủ stack healthy | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/OPS-001/report.md) | Bước 4 phải kiểm tra lại sau khi web sẵn sàng (TC-01, DEF-07) |
| OPS-002 | make seed nạp 3 PDF mẫu tới Sẵn sàng | P2 | ✅ Đạt | 02/11 | [report](../../test_reports/OPS-002/report.md) | Phát hiện DEF-06 |
| OPS-007 | Khởi động lại worker khi đang xử lý: job được thu hồi | P1 | ❌ Không đạt | 02/11 | [report](../../test_reports/OPS-007/report.md) | DEF-03; thu hồi job vẫn hoạt động. Lần đầu không hợp lệ (TC-05), đã chạy lại |
| OPS-008 | Thiếu ANTHROPIC_API_KEY: /ask 503, phần còn lại vẫn chạy | P1 | ✅ Đạt | 02/11 | [report](../../test_reports/OPS-008/report.md) |  |
| OPS-009 | Truy vấn số liệu pilot chạy được | P2 | ✅ Đạt | 02/11 | [report](../../test_reports/OPS-009/report.md) |  |


## 4. Lỗi phát hiện

Mức độ theo [Test_Plan §6.4](Test_Plan.md). Đây là đề xuất của agent, QA / Tech lead cần xác nhận. Chưa tạo GitHub Issue (ngoài phạm vi lượt chạy này).

| Mã | Mức độ | Mô tả | Test case | Bằng chứng |
|---|---|---|---|---|
| DEF-01 | **Critical** (đề xuất, chờ kiểm chứng trên S3 thật) | Tệp > 8 MB (dưới giới hạn 20 MB) đều nhận `storage_error`. `upload_fileobj` của boto3 chuyển sang multipart và S3Mock từ chối `CompleteMultipartUpload` vì thiếu checksum từng phần; 1 MB và 7 MB thành công, 9 MB và 20 MB thất bại. Nếu chỉ xảy ra với S3Mock thì là vấn đề môi trường local, không phải lỗi trên AWS | PERF-003 | [diag-s3-multipart.log](../../test_reports/PERF-003/logs/diag-s3-multipart.log), [steps.log](../../test_reports/PERF-003/logs/steps.log) |
| DEF-02 | **Major** | AI không phản hồi: báo lỗi sau **182,5 s** so với ≤ 30 s (NFR-020), đúng dự báo RISK-008 (`llm_timeout_s = 60`, `max_retries = 2`). Thông điệp và nút "Hỏi lại" đúng. Cần Tech lead / PO quyết định | PERF-004 | [ảnh](../../test_reports/PERF-004/screenshots/04-buoc-3-thong-bao-loi.png), [checks-ui.json](../../test_reports/PERF-004/logs/checks-ui.json) |
| DEF-03 | **Major** (lưu ý môi trường) | PDF 50 trang kết thúc `failed` / `transient_exhausted` sau ~143 s, không bao giờ `ready`: `/embed` vượt timeout 30 s của worker ở cả 3 lần thử. Đo trực tiếp trên máy này: 8 đoạn 31,3 s, 32 đoạn (`BATCH_SIZE`) 124,0 s. TEI giả lập x86 chậm hơn nhiều so với AWS; cần đo lại trên AWS trước khi đóng | PERF-001, OPS-007 | [diag-embed-direct.log](../../test_reports/PERF-001/logs/diag-embed-direct.log), [worker-job-timeline.log](../../test_reports/PERF-001/logs/worker-job-timeline.log) |
| DEF-04 | **Major** (theo ghi chú của UT-027) | Mã `not_found` có trong `ERRORS` nhưng thiếu trong `vi.json`, trái quy tắc AGENTS.md | UT-027 | [steps.log](../../test_reports/UT-027/logs/steps.log) |
| DEF-05 | Minor | Worker thoát hẳn khi mất kết nối PostgreSQL (lỗi không được bắt trong `run_forever`). Compose local không tự khởi động lại nên hàng đợi đứng tới khi chạy tay. Compose production có `restart: unless-stopped`, chưa kiểm chứng trên AWS. Tech lead có thể nâng mức | Phát hiện khi chạy INT-020 → OPS-007 | [run1-worker-all.log](../../test_reports/OPS-007/logs/run1-worker-all.log), [run1-invalid-steps.log](../../test_reports/OPS-007/logs/run1-invalid-steps.log) |
| DEF-06 | Minor | `make fixtures` và `make seed` ghi đè 5 PDF fixture được git theo dõi bằng nội dung khác bản đã commit, làm bẩn cây làm việc. Agent đã `git restore` và đối chiếu shasum trùng | OPS-002 | [report](../../test_reports/OPS-002/report.md) |
| DEF-07 | Minor | `make dev` in URL web trong khi web còn ~1 phút mới phản hồi (`npm ci` mỗi lần khởi động, không có healthcheck) | OPS-001 | [steps.log](../../test_reports/OPS-001/logs/steps.log) |
| E2E-F1 | Minor (31/10, chép lại, không kiểm lại) | Câu hỏi > 2000 ký tự: thông báo chỉ nằm trong tooltip của bộ đếm | E2E-006 | [E2E-summary.md](../../test_reports/E2E-summary.md) |
| E2E-F2 | Minor (31/10, chép lại, không kiểm lại) | Trong lúc `GET /documents` chưa trả về, trang Hỏi đáp hiện ô nhập dùng được, sidebar hiện 0 | E2E-005 | [E2E-summary.md](../../test_reports/E2E-summary.md) |

### Lỗi trong test case / công cụ

Không sửa test case; xử lý trong `test_reports/<ID>/` theo quy ước.

| Mã | Vấn đề | Cách xử lý |
|---|---|---|
| TC-01 | OPS-001: script gọi web ngay sau `make dev`, không chờ `npm ci` | Thêm `steps-recheck.sh`, giữ nguyên log lần đầu |
| TC-02 | INT-021: `head -30` cắt mất dòng `<div id="root">` | Thêm `steps-recheck.sh` |
| TC-03 | INT-012: cột mong đợi cho phép item lỗi, "Tiêu chí đạt" và tên test ghi 502; Blueprint ERR-16 ghi 502, mã trả 202 + lỗi theo từng tệp | Kết luận theo cột mong đợi. **Nếu chốt 502 thì INT-012 là ❌** |
| TC-04 | INT-018, SEC-006: "Tiêu chí đạt" và "Dọn dẹp" ghi sai số bước | Đánh giá theo bảng bước |
| TC-05 | README §8 đặt OPS-007 ngay sau INT-020, nhưng INT-020 làm chết worker và không bật lại (xem DEF-05) | Lần đầu không hợp lệ, lưu log; chạy lại sau khi bật worker |
| TC-06 | `run-cli.mjs` chỉ nhận `### ` ở đầu dòng; output không có newline (`curl -i`) làm dính dòng, mất ảnh riêng của bước sau ở INT-016, INT-020, INT-021 | Dùng ảnh kế tiếp (terminal cộng dồn nên vẫn thấy nội dung) |
| TC-07 | `reset_data` lúc worker đang xử lý sinh log `ForeignKeyViolationError` ở worker | Tác dụng phụ của việc dọn dữ liệu trong test; đã đọc log, không có tham số SQL hay nội dung tài liệu |

## 5. Test case bị chặn

| Mã | Lý do | Điều kiện để chạy |
|---|---|---|
| INT-014 | Bước 4 cần Claude thật; bước 1 passed, bước 5 có cột đúng nhưng `status = ok` chưa kiểm chứng | Có `ANTHROPIC_API_KEY` |
| INT-022 | Gọi Claude thật | Có `ANTHROPIC_API_KEY` |
| EVAL-001 … 005 | Golden set cần Claude thật. Không chạy `make eval`, không có số đo. Khi có khóa cần ghi "chưa đại diện" nếu BD chưa bàn giao PDF thật | Có `ANTHROPIC_API_KEY` (Test_Plan §8 S-5) |
| UI-001 | Tiêu chí "không có khác biệt Major" cần phán đoán chủ quan. Đã kiểm tự động: không có thành phần đã lược bỏ, computed style 18 selector chung trùng (trừ bo góc `textarea`). Agent không thấy khác biệt Major, bảng khác biệt nằm trong [báo cáo](../../test_reports/UI-001/report.md) | BD hoặc người thiết kế xem ảnh và xác nhận |

**Không dùng giả lập để chuyển test bị chặn thành đạt.** Giả lập `/api/v1/ask` chỉ dùng ở nơi test case cho phép: SEC-004, UI-001 (bước chụp ảnh) và E2E-005 … 009 (31/10).

**Đạt nhưng chưa kiểm hết vì thiếu khóa:** SEC-006 chỉ kiểm đường lỗi, OPS-009 chỉ có `qa_log` lỗi, E2E-005 dùng API giả lập.

## 6. Không chạy (ngoài phạm vi localhost, README §7)

| Mã | Lý do |
|---|---|
| PERF-002 | Đo p90 trên AWS với bộ 50 tài liệu |
| SEC-001 | Giới hạn IP / VPN của ALB, cần thử từ mạng ngoài |
| SEC-002 | TLS / ACM trên ALB |
| SEC-003 | SSE-KMS của S3, mã hóa RDS |
| OPS-003, OPS-004 | CI trên GitHub Actions, đẩy image lên ECR |
| OPS-005, OPS-006 | `infra/deploy.sh`, `infra/rollback.sh` trên EC2 |
| UAT-001 … UAT-006 | Đại diện BD thực hiện trên AWS |

## 7. CI

Log CI: <https://github.com/nhtoan3/chat_with_document/actions>. Tại `c02cc72`: job `backend` và `frontend` xanh; job `build` đỏ ở bước `configure-aws-credentials`. Thông tin này do người giao việc cung cấp; lượt chạy này không truy cập GitHub nên không kiểm chứng lại, và không có kết luận test case nào dựa vào CI.

## 8. Ghi nhận khác

- **Worker truy cập Internet lúc chạy:** log có request tới `huggingface.co` (tokenizer của `BAAI/bge-m3`, kèm cảnh báo thiếu `HF_TOKEN`). Không chặn test local, nhưng nên xem lại nếu môi trường AWS hạn chế đường ra.
- **Số đo trên máy này chỉ là tham khảo** theo ghi chú trong các test case PERF; kết luận NFR chính thức đo trên AWS. Các kết quả không đạt vẫn được ghi ❌.
- **PERF-003:** phép đo RAM (`tang_MiB: 6.9`, 2 mẫu) không có giá trị kết luận vì cả 10 tệp bị từ chối. Cần đo lại sau khi xử lý DEF-01.
- **Dữ liệu sinh ra:** đã xóa các PDF ≥ 20 MB trong `test_reports/*/data/` sau khi chạy (được `.gitignore`, sinh lại bằng `make_pdf`).
- **Thay đổi tài liệu từ nguồn khác trong lúc chạy:** so với lúc bắt đầu, cây làm việc xuất hiện thêm việc xóa `docs/*_Checklist.xlsx`, `docs/*_Prompt*.md` và thư mục chưa theo dõi như `docs/04-design/`, `docs/05-development/`. Lượt chạy này không tạo các thay đổi đó và không đụng vào. Không ảnh hưởng `backend/`, `frontend/`, `test_cases/`.
- **Chạy lại:** OPS-007 (lần đầu không hợp lệ, TC-05), UI-003 (lần đầu lỗi selector trong script của agent, chờ hết 300 s, kết quả cùng là Đạt; không có báo cáo lần đầu được giữ lại). Không có lần chạy lại nào để biến ❌ thành ✅ ngoài OPS-001 và INT-021 đã nêu ở TC-01, TC-02.

## 9. Bằng chứng

Mỗi test case có thư mục `test_reports/<ID>/` theo README §3: `report.md`, video, ảnh, `logs/`, script đã chạy. Các test blocked EVAL-*, INT-022 có video và log chứng minh thiếu khóa.

Các bước tiếp theo đề xuất: kiểm tra DEF-01 trên S3 thật; Tech lead / PO quyết định DEF-02; cấp khóa API để chạy các test bị chặn; BD xác nhận UI-001.
