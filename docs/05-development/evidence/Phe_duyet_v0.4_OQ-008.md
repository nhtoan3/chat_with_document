# Phiếu xin quyết định — Phạm vi v0.4 và OQ-008

| Mục | Nội dung |
|---|---|
| Người đề nghị | Huy Toan (PO / Tech lead) |
| Người quyết định | Quản lý giao yêu cầu (STK-001): __________ · Bảo mật / pháp chế (STK-005): __________ |
| Ngày gửi | ___/11/2026 |
| Hạn trả lời | **06/11/2026** (phần duyệt phạm vi đã quá hạn cũ 28/10) |
| Tài liệu kèm theo | [`Implement_plan.md`](../Implement_plan.md) v0.4 · [`intent.md`](../../01-intake/intent.md) |

> **Trạng thái: chưa có quyết định nào.** Mọi ô dưới đây để trống cho người quyết định điền.

## 1. Duyệt phạm vi v0.4

MVP chỉ gồm F1 Xử lý PDF và F2 Hỏi đáp AI, go-live đề xuất 30/11/2026.

☐ Duyệt · ☐ Duyệt có điều kiện: __________ · ☐ Không duyệt

## 2. Chấp nhận 4 đánh đổi

| # | Đánh đổi | Hệ quả | Quyết định |
|---|---|---|---|
| 1 | Không có trích dẫn | Người dùng không kiểm chứng được nguồn câu trả lời; mục tiêu BO-002 không còn được đáp ứng | ☐ Chấp nhận ☐ Không |
| 2 | Không có đăng nhập | Ai trong mạng công ty cũng truy cập được mọi tài liệu; không đếm được số người dùng | ☐ Chấp nhận ☐ Không |
| 3 | Chống bịa chỉ bằng prompt | Tỷ lệ AI bịa khó kiểm soát hơn; chỉ đo được qua golden set | ☐ Chấp nhận ☐ Không |
| 4 | Không gỡ được tài liệu trên giao diện | Tech lead phải xóa trực tiếp trong DB / S3 | ☐ Chấp nhận ☐ Không |

## 3. Quyết định OQ-008

**Câu hỏi:** tài liệu được phân loại bảo mật ở mức nào, và có được gửi nội dung tới dịch vụ AI bên ngoài không?

Phân loại tài liệu: __________ · Yêu cầu nơi lưu trữ dữ liệu: __________

| Chọn | Kết quả | Điều chỉnh kế hoạch |
|---|---|---|
| ☐ | Được dùng Anthropic API | Giữ nguyên |
| ☐ | Chỉ dùng trong AWS của tổ chức | Đổi adapter sang Claude trên Bedrock, khoảng 1 ngày; go-live giữ nguyên |
| ☐ | Không được gửi dữ liệu ra ngoài | Thêm khoảng 1 tuần dựng LLM tự vận hành; go-live lùi tới khoảng 07/12/2026 |

## 4. Các xác nhận đi kèm

| Mục | Đề xuất | Quyết định |
|---|---|---|
| OQ-001: người phê duyệt, người review từng loại tài liệu | Theo [`stakeholders.md`](../../01-intake/stakeholders.md) §4 | ☐ Đồng ý ☐ Sửa: __________ |
| Risk tier của intent | High | ☐ Đồng ý ☐ Mức khác: __________ |
| OQ-006: hạn bàn giao | 30/11/2026 | ☐ Đồng ý ☐ Ngày khác: __________ |
| OQ-007: ngân sách, gồm chi phí AI | Chưa có số đề xuất | __________ |

## 5. Ký xác nhận

| Vai trò | Họ tên | Ngày | Ký |
|---|---|---|---|
| Quản lý | | | |
| Bảo mật / pháp chế | | | |

## 6. Sau khi có quyết định

PO thực hiện:

1. Ghi kết quả vào BRD §12 và `intent.md` §7, §8.
2. Nếu OQ-008 không chọn phương án 1, cập nhật kế hoạch theo `Implement_plan.md` §4.
3. Nâng trạng thái `Implement_plan.md` và `intent.md` khỏi `Draft`.
