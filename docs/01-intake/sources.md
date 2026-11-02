# Nguồn dữ liệu — "Chat với tài liệu" (MVP)

> **SRC-CWD-001** · v0.1 (`Draft`) · 2026-11-02 · Tách từ `docs/02-requirements/BRD.md` §0, §13.2 và §15.1, bổ sung tình trạng tại ngày lập.

## 1. Nguồn yêu cầu

| ID | Nguồn | Loại | Chủ sở hữu | Ngày | Nội dung chứng minh | Độ tin cậy |
|---|---|---|---|---|---|---|
| SRC-001 | Yêu cầu của quản lý: mục 2.1 của `docs/BRD_Prompt_IEEE_standard.md` (trích nguyên văn ở §2) | Sponsor brief | Quản lý [TBD: OQ-001] | 2026-10-20 | Vấn đề, người dùng mục tiêu, mục tiêu MVP, ràng buộc web + PDF + chat AI | Sơ cấp; mô tả là "bối cảnh giả sử" |
| SRC-002 | Đề xuất của nhóm BA trong `BRD.md` | Phân tích BA | Nhóm BA | 2026-10-20 | Tính năng bổ sung, quy tắc, chỉ số | Đề xuất; **chờ quản lý xác nhận (OQ-013)** |

## 2. Trích nguyên văn SRC-001

> Bối cảnh giả sử: trong một dự án kinh doanh, có nhiều tài liệu PDF mà đội phát triển kinh doanh khó lòng nắm bắt đầu đủ, mỗi khi cần tìm một thông tin thường tốn thời gian tổng hợp từ nhiều file pdf.
> Bạn nhận được yêu cầu từ quản lý, phát triển một MVP cho một công cụ "Chat với tài liệu".
> Mục tiêu: một ứng dụng web cho phép người dùng upload pdf file và chat với AI để truy vấn về nội dung cả các tài liệu đã được upload.
> Có thể có thêm tính năng theo gợi ý từ đội BA.

## 3. Tài liệu dẫn xuất

Các tài liệu này do dự án tự soạn từ nguồn ở §1, nên **không phải bằng chứng độc lập** về nhu cầu.

| Tài liệu | Phiên bản | Trạng thái |
|---|---|---|
| `docs/02-requirements/BRD.md` | 0.1 | `Draft` |
| `docs/02-requirements/PRD.md` | 0.1 | `Draft` |
| `docs/02-requirements/User_Stories.md` | 0.2 | `Draft`, chưa theo v0.4 |
| `docs/04-design/SAD.md` | 0.2 | `Draft`, chưa theo v0.4 |
| `docs/05-development/Implement_plan.md` | 0.4 | `Draft`; **phạm vi hiện hành** nhưng chưa có bản ghi duyệt |

## 4. Nguồn dữ liệu còn thiếu

| Nguồn cần có | Dùng cho | Người cung cấp | Liên quan | Tình trạng tại 2026-11-02 |
|---|---|---|---|---|
| Biên bản phỏng vấn người dùng | Xác nhận persona, nhu cầu | Nhóm BA + đội BD | OQ-018; `docs/02-requirements/interviews/` theo quy trình | Chưa có |
| Quy trình tìm kiếm hiện tại và số liệu baseline | MET-001 | Đội BD | OQ-002 | Chưa có |
| Quy mô đội BD, tần suất tìm kiếm | MET-003, quy mô | Quản lý | OQ-005 | Chưa có |
| Bộ PDF mẫu thật của dự án | Kiểm tra ASM-001, UAT | Đội BD | DEP-002, OQ-012 | Chưa có; repo chỉ có fixture giả lập |
| Golden set ≥ 30 câu positive + ≥ 10 câu negative | KR2.1, KR2.3, T-023 | Đội BD | DEP-002, T-008 | Chưa có; `golden.yaml` chỉ có 6 câu mẫu trên fixture |
| Chính sách bảo mật dữ liệu, phân loại tài liệu | Chọn nhà cung cấp AI | Bảo mật / pháp chế | OQ-008, OQ-016 | Chưa có |
| Dải IP / VPN công ty | Giới hạn truy cập ALB | IT | T-006 | Chưa có |
| Ngân sách | CON-006 | Quản lý | OQ-007 | Chưa có |

## 5. Tài liệu tham chiếu

| Tên | Phiên bản | Vị trí |
|---|---|---|
| Quy trình Agentic SDLC | — | `sdlc/agentic-sdlc-process.md` |
| BRD Prompt — IEEE standard | 1.0 | `docs/BRD_Prompt_IEEE_standard.md` |
| ISO/IEC/IEEE 29148 — Requirements engineering | 2018 | Chuẩn quốc tế |

## 6. Quy tắc sử dụng nguồn

- Fixture PDF trong repo chỉ là dữ liệu giả lập; không commit dữ liệu thật của khách hàng.
- Trước khi OQ-008 được đóng, không dùng tài liệu thật để thử với dịch vụ AI bên ngoài.
- Nội dung câu hỏi, câu trả lời và văn bản tài liệu không được ghi vào log hay `qa_log`.
