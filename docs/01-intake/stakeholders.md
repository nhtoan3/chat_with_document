# Bên liên quan — "Chat với tài liệu" (MVP)

> **STK-CWD-001** · v0.1 (`Draft`) · 2026-11-02 · Tách từ `docs/02-requirements/BRD.md` §6, bổ sung vai trò từ `docs/07-verification/Test_Plan.md` §12 và phạm vi `Implement_plan.md` v0.4.
> Tên người chưa xác định được ghi `[TBD: OQ-001]`.

## 1. Bên liên quan nghiệp vụ

| ID | Bên liên quan | Vai trò | Mối quan tâm | Ảnh hưởng | Nhu cầu | Người cụ thể | Nguồn |
|---|---|---|---|---|---|---|---|
| STK-001 | Quản lý giao yêu cầu | Nhà tài trợ / người phê duyệt | MVP chứng minh được giá trị, đúng phạm vi | Cao | SN-005 | [TBD: OQ-001] | SRC-001 |
| STK-002 | Đội phát triển kinh doanh (BD) | Người dùng chính; giao dữ liệu mẫu, chấm golden set, làm UAT | Tìm thông tin nhanh, chính xác | Cao | SN-001..004 | [TBD: OQ-001] | SRC-001 |
| STK-003 | Nhóm BA | Phân tích, đề xuất tính năng | Phạm vi rõ ràng | Trung bình | SN-007 | [TBD] | SRC-001 |
| STK-004 | Đội phát triển | Xây dựng MVP | Yêu cầu rõ, kiểm chứng được | Trung bình | SN-008 | Xem §3 | SRC-001 |
| STK-005 | Bảo mật / IT / pháp chế (nếu có) | Kiểm soát dữ liệu, cấp IP / VPN; **có thể chặn** việc đưa vào sử dụng | Tài liệu không bị lộ | Cao | SN-006 | [TBD: OQ-001] | Chưa xác minh — OQ-008 |

## 2. Nhu cầu và mức đáp ứng ở v0.4

| ID | Bên liên quan | Nhu cầu | Ưu tiên | Mức đáp ứng ở v0.4 |
|---|---|---|---|---|
| SN-001 | STK-002 | Tìm được thông tin mà không phải mở từng tệp PDF | Must | Có (F2) |
| SN-002 | STK-002 | Nhận câu trả lời tổng hợp từ nhiều tài liệu | Must | Có, không có tinh chỉnh đa nguồn riêng (US-012) |
| SN-003 | STK-002 | Kiểm chứng được câu trả lời lấy từ tài liệu, trang nào | Must | **Không:** đã lược bỏ trích dẫn (đánh đổi 1) |
| SN-004 | STK-002 | Tự đưa tài liệu mới vào để hỏi | Must | Có (F1) |
| SN-005 | STK-001 | Có MVP để đánh giá giá trị | Must | Có; khó đo mức dùng theo người (MET-003) |
| SN-006 | STK-005 | Chỉ người có quyền truy cập được tài liệu | Should | **Một phần:** chỉ giới hạn theo mạng IP / VPN (đánh đổi 2) |
| SN-007 | STK-003 | Phạm vi MVP được chốt rõ | Should | Chờ duyệt v0.4 |
| SN-008 | STK-004 | Mỗi yêu cầu có tiêu chí chấp nhận đo được | Should | Có trong 24 task; các ngưỡng ⚑ còn chờ duyệt |

## 3. Vai trò thực hiện

| Vai trò | Người | Trách nhiệm chính |
|---|---|---|
| PO | Huy Toan | Chủ sở hữu intent, chấp nhận rủi ro trong thẩm quyền, chủ trì UAT |
| Tech lead | Huy Toan | CI, AWS, kiến trúc, review PR |
| BE1 / BE2 | [TBD] | F1 backend / F2 backend |
| FE | [TBD] | Giao diện |
| QA | [TBD] | Điều phối kiểm thử, chấm eval, báo cáo tổng kết |
| BA | [TBD] | Soạn bộ câu hỏi tạm nếu BD giao trễ |
| IT | [TBD] | Cung cấp dải IP / VPN |

## 4. Ai duyệt gì

Theo `sdlc/agentic-sdlc-process.md` §10. Cột "Hiện tại" ghi đúng tình trạng tại ngày lập tài liệu.

| Phase | Tài liệu | Người duyệt theo quy trình | Người được đề xuất | Hiện tại |
|---|---|---|---|---|
| 1. Intake | `intent.md` | PO | **Quản lý** (xem §5) | Chưa duyệt |
| 2. Requirements | `BRD.md` | PM/PO | Quản lý | Chưa duyệt |
| 3. Analysis | `PRD.md`, `User_Stories.md` | PM/PO + Tech lead | Quản lý + một reviewer kỹ thuật khác | Chưa duyệt |
| 4. Design | `SAD.md`, `Blueprint_Design.md` | Architect + Tech lead | Reviewer kỹ thuật độc lập [TBD] | Chưa duyệt |
| 5. Planning | `Implement_plan.md`, `tasks/` | PM/PO + Tech lead | Quản lý + một reviewer kỹ thuật khác | Chưa duyệt |
| 7. Verify | `Test_Plan.md` | QA + Reviewer | QA [TBD] + reviewer [TBD] | Chưa duyệt |
| 8. Review | PR | Reviewer ≠ tác giả | Developer khác [TBD] | Chưa có PR / review |
| 9. Release | Go / no-go | Release owner | Quản lý | Chưa đến hạn |

## 5. Xung đột vai trò cần xử lý

Huy Toan đang đứng tên tác giả của BRD, PRD, User Stories, SAD, kế hoạch và Test Plan, đồng thời giữ cả vai trò PO và Tech lead, tức cũng là người duyệt theo bảng §4. Điều này trái với luật "người tạo nội dung ≠ người phê duyệt".

Cột "Người được đề xuất" ở §4 là cách gỡ; Quản lý cần xác nhận khi đóng OQ-001.

## 6. Kế hoạch tương tác

| Bên liên quan | Cần từ họ | Kênh / dịp | Mốc |
|---|---|---|---|
| Quản lý | Duyệt v0.4, intent, risk tier; đóng OQ-001, 006, 007 | Phiếu `Phe_duyet_v0.4_OQ-008.md` | Càng sớm càng tốt; hạn cũ 28/10 đã qua |
| Bảo mật / IT | Quyết định OQ-008; dải IP / VPN | Phiếu trên; yêu cầu riêng tới IT | 06/11/2026 |
| Đội BD | PDF mẫu, golden set, baseline; ≥ 2 người làm UAT | Làm việc trực tiếp | 05/11/2026; UAT 26/11/2026 |
| Quản lý, PO, Tech lead | Quyết định go / no-go | Họp | 27/11/2026 |
