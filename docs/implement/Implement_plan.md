# Kế hoạch triển khai — "Chat với tài liệu" (MVP)

> **IMP-CWD-001** · v0.4 (`Draft`) · 2026-10-26 · Huy Toan (Tech lead / PO)
> **Task chi tiết cho developer:** [`tasks/README.md`](tasks/README.md) — 24 task, mỗi task một file.
>
> Tài liệu này chỉ trả lời: **làm gì, khi nào, điều kiện gì**.

**Lịch sử phiên bản**

| Phiên bản | Thay đổi |
|---|---|
| v0.1 | Kế hoạch đầy đủ: 96 SP, go-live 25/01/2027 |
| v0.2 | Rút gọn nội dung tài liệu |
| v0.3 | Rút gọn còn 16 story (40 SP); go-live 14/12/2026 |
| **v0.4** | **Chỉ giữ 2 tính năng: Xử lý PDF và Hỏi đáp AI; 28 ngày công; go-live 30/11/2026** |

---

## 1. Phạm vi

| Tính năng | Bao gồm | Story gốc |
|---|---|---|
| **F1 — Xử lý PDF** | Chọn và tải lên tối đa 10 PDF (≤ 20 MB) · trích văn bản, chia đoạn, embedding · danh sách tài liệu với trạng thái tự cập nhật · báo lý do khi tệp lỗi | US-005, 006, 007 (bản tối giản) |
| **F2 — Hỏi đáp AI** | Nhập câu hỏi → AI trả lời chỉ dựa trên nội dung các tài liệu Sẵn sàng (truy xuất vector + Claude) · tiếng Việt · báo "không tìm thấy" bằng prompt | US-008, 011, 015 (bản tối giản) |

**Lược bỏ khỏi MVP** (so với v0.3):

- **Đăng nhập / đăng xuất, phân quyền, hội thoại riêng tư** (US-001, 002, 003, 023). Thay bằng **giới hạn truy cập theo IP / VPN công ty** ở tầng mạng.
- **Trích dẫn tài liệu + trang và mở PDF tại trang** (US-013, 017).
- **Kiểm tra "không tìm thấy" phía server — AnswerGuard, ngưỡng τ** (US-014). Hành vi này giờ chỉ dựa vào prompt.
- **Câu trả lời hiện dần — streaming** (US-016). Người dùng chờ khoảng 10–20 giây với spinner.
- **Gỡ tài liệu, tinh chỉnh đa nguồn riêng** (US-010, 012).
- **Việc nền tảng tùy chọn:** PoC, rà soát bảo mật riêng, a11y, runbook đầy đủ, quét bảo mật trong CI.

**Đánh đổi cần quản lý chấp nhận:**

| # | Đánh đổi | Hệ quả |
|---|---|---|
| 1 | **Không có trích dẫn** | Người dùng không kiểm chứng được câu trả lời từ đâu ra. Rủi ro dùng thông tin sai (RSK-001) tăng; mục tiêu BO-002 "câu trả lời kiểm chứng được" **không còn được đáp ứng** |
| 2 | **Không có đăng nhập** | Ai trong mạng công ty cũng truy cập được mọi tài liệu. Không đếm được số người dùng (MET-003), chỉ đếm được số câu hỏi |
| 3 | **Chống bịa chỉ bằng prompt** | Tỷ lệ AI bịa khó kiểm soát hơn; chỉ đo được qua golden set |
| 4 | **Không gỡ được tài liệu trên giao diện** | Cần Tech lead xóa trực tiếp trong DB / S3 khi tài liệu lỗi thời |

> `User_Stories.md` v0.2 và `SAD.md` v0.2 **chưa được cập nhật** theo phạm vi v0.4. Trong trường hợp có khác biệt, kế hoạch này và thư mục `tasks/` có hiệu lực.

---

## 2. Lịch

| Giai đoạn | Thời gian | Nội dung | Task | Ngày công | Mốc |
|---|---|---|---|---|---|
| **S0 — Nền tảng** | 02/11 → 06/11 | Repo, Docker, CI, DB, AWS (giới hạn IP), frontend shell, golden set | T-001 … T-008 | 8 | **M0** Local + AWS chạy; CI xanh |
| **S1 — Phát triển** | 09/11 → 20/11 | **F1** Xử lý PDF (BE1 + FE) · **F2** Hỏi đáp AI (BE2 + FE), làm song song | T-009 … T-016, T-017 … T-022 | 16,5 | **M1** Tải PDF → hỏi → nhận câu trả lời trên AWS |
| **Ổn định & go-live** | 23/11 → 27/11 | Tinh chỉnh chất lượng theo golden set, UAT, go / no-go | T-023, T-024 | 3,5 | **M2** UAT ký xác nhận |
| **Go-live** | **30/11/2026** | Mở cho đội BD | — | — | **M3** |
| Pilot | 30/11 → 31/12/2026 | Đo số câu hỏi, độ trễ (`qa_log`); khảo sát người dùng | — | — | **M4** Báo cáo đánh giá ngày 08/01/2027 |

**Tổng:** 24 task · 28 ngày công · **go-live sớm hơn v0.3 hai tuần**.

**Phân bổ Sprint 1 (đề xuất):**

| Người | Task | Ngày công |
|---|---|---|
| BE1 | F1 backend: T-009..T-014, T-016 | 7,5 |
| BE2 | F2 backend: T-017..T-020, T-022 | 5,5 |
| FE | T-015 (màn hình Tài liệu), T-021 (màn hình Hỏi đáp) | 3,5 |

> Khối lượng frontend chỉ khoảng 4,5 ngày cho cả dự án, nên **FE có thể làm bán thời gian**, hoặc một backend kiêm phần frontend.

**Chuỗi task quyết định ngày go-live:** T-001 → T-002 → T-004 → T-010 → T-013 → T-020 → T-022 → T-023 → T-024.

---

## 3. Rủi ro chính

| Rủi ro | Mức | Giảm thiểu | Dấu hiệu cần hành động |
|---|---|---|---|
| OQ-008 không cho dùng Anthropic API với dữ liệu thật | Cao | Lớp AI tách riêng qua `LLMPort` | Có quyết định trước 06/11 → áp dụng §4 |
| Chất lượng câu trả lời thấp, không có trích dẫn để người dùng tự kiểm chứng | Cao | Golden set + tinh chỉnh prompt ở T-023; hướng dẫn sử dụng nhắc đối chiếu tài liệu gốc | < 80% câu positive đúng ngày 26/11 |
| Truy cập trái phép do không có đăng nhập | Cao | Security group ALB chỉ cho phép IP / VPN công ty (T-006); kiểm tra từ mạng ngoài trước go-live | Có thể truy cập từ mạng ngoài |
| BD giao dữ liệu mẫu chậm | Trung bình | Yêu cầu ngay tuần này; BA soạn bộ tạm 20 câu | Chưa có dữ liệu ngày 05/11 |
| Độ trễ > 20 s khiến người dùng bỏ dùng | Trung bình | Giảm `QA_TOP_N`, `max_tokens`; spinner có thông báo thời gian chờ | p90 trong `qa_log` > 20 s |

---

## 4. Phương án dự phòng (quyết định tại 06/11)

| Kết quả | Điều chỉnh |
|---|---|
| OQ-008: được dùng Anthropic API | Giữ nguyên kế hoạch |
| OQ-008: chỉ dùng trong AWS của tổ chức | Đổi adapter sang Claude trên Bedrock (khoảng 1 ngày, T-019); go-live giữ nguyên |
| OQ-008: không được gửi dữ liệu ra ngoài | Thêm khoảng 1 tuần dựng LLM tự vận hành; go-live lùi tới khoảng 07/12/2026 |
| IT không cấp được dải IP / VPN | **Bắt buộc thêm lớp xác thực** trước go-live: ALB OIDC (nếu có SSO) hoặc Basic Auth ở Nginx (khoảng 0,5–1 ngày) |

---

## 5. Việc cần làm ngay (tuần 26/10 → 30/10)

| Việc | Phụ trách | Hạn |
|---|---|---|
| Duyệt phạm vi v0.4 và 4 đánh đổi ở §1 | Quản lý | 28/10 |
| Gửi yêu cầu quyết định OQ-008 kèm hạn 06/11 | PO | 27/10 |
| Xin IT danh sách IP / VPN công ty cho ALB | Tech lead | 30/10 |
| Yêu cầu BD chuẩn bị bộ PDF mẫu + ≥ 30 câu positive + ≥ 10 câu negative | BA | 27/10 |
| Xin tài khoản AWS, khóa Anthropic API, GitHub Actions | Tech lead | 30/10 |
