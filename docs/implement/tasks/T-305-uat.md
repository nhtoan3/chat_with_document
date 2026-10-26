# T-305 — UAT với đội BD

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định (07/12 → 11/12/2026) |
| Loại | Kiểm thử |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | PO + QA |
| Phụ thuộc (phải xong trước) | [T-301](T-301-quality-tuning.md), [T-302](T-302-security-review.md) |
| Mở khóa cho | [T-306](T-306-go-live.md) |
| Nhánh git | `feat/T-305-uat` |
| Trạng thái | `To do` |

## Mục tiêu

Đại diện đội BD xác nhận MVP dùng được cho công việc thật.

## Phạm vi & đặc tả

**Người tham gia:** ≥ 2 đại diện BD, PO, QA.

**Môi trường:** AWS, với dữ liệu thật nếu OQ-008 cho phép, ngược lại dùng bộ dữ liệu mẫu.

| Kịch bản | Nội dung | Tiêu chí đạt |
|---|---|---|
| SC-01 | Tra cứu điều khoản trong hợp đồng, mở trích dẫn kiểm chứng | Câu trả lời đúng, trích dẫn đúng trang |
| SC-03 | Hỏi thông tin không có trong tài liệu | Nhận "không tìm thấy" |
| SC-04 | Admin gỡ tài liệu cũ, tải bản mới; hỏi lại | Câu trả lời dựa trên bản mới |
| Bổ sung | Tải PDF scan, PDF có mật khẩu | Thông báo lỗi dễ hiểu |

**Ghi nhận:** mỗi lỗi ghi vào backlog với mức độ (Blocker / Major / Minor). Blocker phải được sửa trước go-live.

**Kết thúc:** biên bản UAT có chữ ký (`docs/implement/evidence/UAT.md`).

## Các bước thực hiện

1. Chuẩn bị tài khoản và dữ liệu.
2. Chạy phiên UAT (khoảng 2 giờ).
3. Sửa Blocker.
4. Ký biên bản.

## File cần tạo / sửa

- `docs/implement/evidence/UAT.md`

## Tiêu chí hoàn thành

- [ ] Biên bản UAT đã ký; 0 lỗi Blocker còn mở.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- (Chính là task kiểm thử.)

## Tham chiếu

- [PRD.md](../../requirements/PRD.md) §3.2 (SC-01..05), §6.1
