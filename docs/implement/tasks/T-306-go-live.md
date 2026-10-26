# T-306 — Go-live

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định (07/12 → 11/12/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | TL + PO |
| Phụ thuộc (phải xong trước) | [T-305](T-305-uat.md), [T-304](T-304-runbook.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-306-go-live` |
| Trạng thái | `To do` |

## Mục tiêu

Mở hệ thống cho đội BD vào thứ Hai 14/12/2026.

## Phạm vi & đặc tả

**Thứ Sáu 11/12 — họp go / no-go** (Quản lý, PO, Tech lead), dựa trên:

- kết quả T-301 (chất lượng);
- T-302 (bảo mật);
- T-305 (UAT);
- quyết định OQ-008 về dữ liệu thật.

**Nếu go — cuối tuần hoặc sáng thứ Hai:**

1. Deploy tag đã qua UAT; chạy `make eval` lần cuối.
2. Xóa dữ liệu thử nghiệm (tài liệu mẫu, hội thoại test) nếu sẽ dùng dữ liệu thật.
3. Tạo tài khoản đội BD bằng CLI; gửi mật khẩu tạm qua kênh an toàn.
4. Đặt hạn mức chi tiêu trong Anthropic Console; bật cảnh báo chi phí AWS.
5. Gửi thông báo kèm hướng dẫn sử dụng 1 trang (cách tải PDF, cách hỏi, cách kiểm tra trích dẫn, giới hạn của MVP, đầu mối hỗ trợ).
6. Theo dõi log trong 2 giờ đầu.

## Các bước thực hiện

1. Họp go / no-go.
2. Thực hiện checklist.
3. Thông báo cho người dùng.

## File cần tạo / sửa

- `docs/implement/Huong_dan_su_dung.md`

## Tiêu chí hoàn thành

- [ ] Đội BD đăng nhập được và đặt câu hỏi đầu tiên; không có lỗi 5xx trong 2 giờ đầu.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Smoke test sau deploy.

## Tham chiếu

- [Implement_plan.md](../Implement_plan.md) §2 (M3, M4)
