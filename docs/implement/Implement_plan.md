# Kế hoạch triển khai — "Chat với tài liệu" (MVP)

> **IMP-CWD-001** · v0.3 (`Draft`) · 2026-10-26 · Huy Toan (Tech lead / PO)
> **Đầu vào:**
> - `docs/requirements/User_Stories.md` v0.2: phạm vi rút gọn, 40 SP
> - `docs/design/SAD.md` v0.2: "Phạm vi kiến trúc cho MVP", ADR-010..012
>
> Tài liệu này chỉ trả lời: **làm gì, khi nào, điều kiện gì**. Chi tiết kỹ thuật nằm ở SAD; AC và DoR/DoD nằm ở `User_Stories.md`.

**Lịch sử phiên bản**

| Phiên bản | Thay đổi |
|---|---|
| v0.1 | Kế hoạch đầy đủ: 96 SP, go-live 25/01/2027 |
| v0.2 | Rút gọn nội dung tài liệu |
| **v0.3** | **Rút gọn phạm vi còn 40 SP; go-live 14/12/2026** |

---

## 1. Tóm tắt

| Mục | Nội dung |
|---|---|
| Phạm vi go-live | 16 story — 40 SP (`User_Stories.md` §2). 8 story hoãn sang giai đoạn 2 |
| Cách làm | Sprint 0 (1 tuần) + 2 sprint (2 tuần) + 1 tuần ổn định / UAT |
| Thời gian | Phát triển **02/11 → 11/12/2026** · Go-live **14/12/2026** · Pilot **14/12/2026 → 15/01/2027** · Đánh giá **22/01/2027** |
| Đội ngũ (đề xuất) | 1 Tech lead (kiêm DevOps), 2 Backend, 1 Frontend, QA 50%, PO/BA 50% — khoảng 20–22 SP/sprint |
| Hạn quyết định | **06/11/2026**: OQ-008 (AI bên ngoài), OQ-014 (SSO / tài khoản nội bộ), OQ-010 (ngôn ngữ) và dữ liệu mẫu từ BD (DEP-002) |

> So với v0.1, go-live **sớm hơn 6 tuần** và pilot kết thúc trước Tết. Lịch và đội ngũ vẫn là **đề xuất**, chờ quản lý xác nhận (OQ-006).

---

## 2. Lịch

| Giai đoạn | Thời gian | Mục tiêu | Story | SP | Mốc |
|---|---|---|---|---|---|
| **S0** (1 tuần) | 02/11 → 06/11 | Dựng nền tảng, giảm rủi ro | Hạng mục nền tảng (§3) | — | **M0** Local + môi trường AWS chạy; CI xanh; có kết quả PoC; các OQ đã quyết |
| **S1** | 09/11 → 20/11 | Đăng nhập, tải lên, xử lý, truy xuất | US-001, 023, 002, 003, 005, 006, 007, 008, 010 | 18 | **M1** Tải PDF → "Sẵn sàng" → truy xuất được đoạn liên quan |
| **S2** | 23/11 → 04/12 | Hỏi đáp có trích dẫn | US-011, 012, 013, 014, 015, 016, 017 | 22 | **M2** Xong toàn bộ 16 story; golden eval đạt ngưỡng |
| **Ổn định + UAT** (1 tuần) | 07/12 → 11/12 | Tinh chỉnh chất lượng, sửa lỗi, UAT | — | — | **M3** Đạt launch gate (PRD §6.1, phần áp dụng cho MVP); UAT ký xác nhận |
| Go-live | 14/12/2026 | Mở cho đội BD | — | — | **M4** |
| Pilot | 14/12 → 15/01/2027 | Đo KR1–KR3 | — | — | **M5** Báo cáo đánh giá ngày 22/01/2027 |

**Ghi chú:**

- **Chuỗi việc quyết định ngày go-live:** S0 → US-005 → US-006 → US-008 → US-011 → US-013 / US-014 → tinh chỉnh golden set → launch gate.
- **Tài khoản người dùng** được tạo bằng script quản trị, vì US-004 đã hoãn.
- **Pilot có nghỉ Tết Dương lịch**, nên thực tế còn khoảng 4 tuần làm việc.

---

## 3. Hạng mục nền tảng (Sprint 0, không tính SP)

| Hạng mục | Kết quả |
|---|---|
| Repo, local, CI | Cấu trúc mã theo Blueprint §3.1; `docker compose up` chạy `web`, `api`, `worker`, `tei`, `postgres`, `minio`; CI gồm lint, test, `pip-audit`, gitleaks |
| Môi trường AWS | EC2 + Docker Compose, RDS PostgreSQL, S3 (SSE-KMS); log JSON → CloudWatch; deploy bằng script |
| CSDL | Alembic baseline gồm các bảng MVP (SAD "Phạm vi kiến trúc cho MVP"): thêm `sessions`, bỏ `analytics_events`, bỏ partition |
| Khung ứng dụng | API skeleton + lỗi ERR-xx + phiên + CSRF + audit; SPA shell + design system lấy từ `html_design` |
| PoC | **AR-01** độ trễ LLM · **AR-02** tốc độ embedding trên CPU. AR-03 (full-text tiếng Việt) để sau, chỉ làm nếu golden set cho thấy truy xuất vector chưa đủ |
| Golden set | BD bàn giao bộ PDF mẫu + ≥ 50 câu hỏi có đáp án + ≥ 10 câu hỏi âm tính; script chạy golden eval bắt buộc trước mỗi lần deploy |

---

## 4. Rủi ro chính

| Rủi ro | Mức | Giảm thiểu | Dấu hiệu cần hành động |
|---|---|---|---|
| OQ-008 không cho dùng AI bên ngoài | Cao | Lớp AI đã tách riêng qua `LLMPort` | Có quyết định trước 06/11 → áp dụng §5 |
| Chất lượng câu trả lời chưa đạt KR2.x | Cao | Golden eval từ S2; dành tuần ổn định để tinh chỉnh; thêm full-text (ADR-003) nếu cần | KR2.1 < 70% cuối S2 |
| BD giao dữ liệu mẫu chậm | Cao | Yêu cầu ngay tuần này; BA soạn bộ tạm 20 câu | Chưa có dữ liệu ngày 05/11 |
| Chỉ một môi trường: lỗi deploy ảnh hưởng người dùng pilot | Trung bình | Golden eval + smoke test trước deploy; deploy ngoài giờ; giữ image cũ để rollback | Có sự cố sau deploy |
| Độ trễ AI vượt 15 s (AR-01) | Trung bình | Giảm số đoạn gửi cho AI; giảm `max_tokens` | p90 > 15 s trong PoC |

---

## 5. Phương án dự phòng (quyết định tại 06/11)

| Kết quả | Điều chỉnh |
|---|---|
| OQ-008: được dùng Anthropic API | Giữ nguyên kế hoạch |
| OQ-008: chỉ dùng trong AWS của tổ chức | Thêm adapter Bedrock ở S2 (khoảng 3 SP); go-live giữ nguyên hoặc lùi tối đa 1 tuần |
| OQ-008: không được gửi dữ liệu ra ngoài | Thêm 1 sprint dựng LLM tự vận hành; go-live lùi tới khoảng **04/01/2027** |
| OQ-008: chưa có quyết định | Chỉ dùng dữ liệu mẫu; go-live bị chặn |
| OQ-014: dùng SSO | Cần IT cấp client ID trước 09/11; US-001 tăng khoảng 2 SP |

---

## 6. Việc cần làm ngay (tuần 26/10 → 30/10)

| Việc | Phụ trách | Hạn |
|---|---|---|
| Duyệt phạm vi rút gọn v0.2 (story bị hoãn, đánh đổi) và lịch mới | Quản lý | 28/10 |
| Gửi yêu cầu quyết định OQ-008, OQ-014, OQ-010 kèm hạn 06/11 | PO | 27/10 |
| Yêu cầu BD chuẩn bị bộ PDF mẫu và câu hỏi chuẩn | BA | 27/10 |
| Xin tài khoản AWS, khóa Anthropic API, GitHub Actions | Tech lead | 30/10 |
| Tạo backlog 16 story MVP + hạng mục nền tảng | PO | 30/10 |
