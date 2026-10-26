# T-024 — UAT và go-live

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định & go-live (23/11 → 27/11/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | TL + PO + QA |
| Phụ thuộc (phải xong trước) | [T-023](T-023-quality-tuning.md), [T-015](T-015-documents-ui.md), [T-021](T-021-ask-ui.md), [T-006](T-006-aws-environment.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-024-uat-go-live` |
| Trạng thái | `To do` |

## Mục tiêu

Đội BD xác nhận dùng được và hệ thống mở cho đội BD vào **30/11/2026**.

## Phạm vi & đặc tả

**UAT (thứ Năm 26/11):** ≥ 2 đại diện BD, trên môi trường AWS.

| Kịch bản | Tiêu chí đạt |
|---|---|
| Tải lên các PDF thật của dự án (nếu OQ-008 cho phép) | Tất cả ở trạng thái Sẵn sàng hoặc báo lỗi rõ ràng |
| Hỏi 10 câu thường gặp trong công việc | ≥ 8 câu trả lời dùng được |
| Hỏi 3 câu không có trong tài liệu | Nhận "Không tìm thấy thông tin…" |

Biên bản UAT ghi vào `docs/implement/evidence/UAT.md`.

**Go / no-go (thứ Sáu 27/11):** Quản lý, PO, Tech lead — dựa trên UAT, T-023 và quyết định OQ-008.

**Go-live (thứ Hai 30/11):**

1. Deploy tag đã qua UAT.
2. Xác nhận giới hạn IP / VPN (T-006).
3. Đặt hạn mức chi tiêu trong Anthropic Console.
4. Gửi hướng dẫn sử dụng 1 trang: cách tải PDF, cách hỏi, giới hạn (chưa có trích dẫn — hãy đối chiếu tài liệu gốc; câu trả lời mất 10–20 giây).
5. Ghi trong README: lệnh deploy / rollback và truy vấn số liệu `SELECT date_trunc('week', created_at), count(*), percentile_cont(0.9) WITHIN GROUP (ORDER BY latency_ms) FROM qa_log GROUP BY 1`.

## Các bước thực hiện

1. Chuẩn bị UAT.
2. Chạy UAT.
3. Họp go / no-go.
4. Go-live và theo dõi log 2 giờ đầu.

## File cần tạo / sửa

- `docs/implement/evidence/UAT.md`
- `docs/implement/Huong_dan_su_dung.md`

## Tiêu chí hoàn thành

- [ ] Biên bản UAT đã ký.
- [ ] Đội BD truy cập được từ mạng công ty và hỏi được câu đầu tiên.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Smoke test sau deploy.

## Ngoài phạm vi task này

- Rà soát bảo mật riêng, a11y, runbook đầy đủ (đã lược bỏ).

## Tham chiếu

- [Implement_plan.md](../Implement_plan.md) §2
