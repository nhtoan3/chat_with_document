# T-009 — PoC AR-02: đo thông lượng embedding trên CPU

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Sprint 0 (02/11 → 06/11/2026) |
| Loại | Backend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | BE1 |
| Phụ thuộc (phải xong trước) | [T-002](T-002-docker-compose.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-009-poc-embedding` |
| Trạng thái | `To do` |

## Mục tiêu

Xác nhận một PDF 50 trang được embedding xong trong ≤ 60 s trên cấu hình CPU dự kiến (NFR-003).

## Phạm vi & đặc tả

- **Tạo chunk:** dùng PDF mẫu 50 trang → khoảng 100–150 chunk × 500 token (chunker đơn giản tạm thời nếu T-115 chưa xong).
- **Gọi TEI:** `POST /embed` theo lô 32, `normalize: true`. Đo tổng thời gian và thời gian mỗi lô.
- **Chạy trên** EC2 `m7i.2xlarge` với TEI giới hạn 3 vCPU (`cpus: 3` trong compose). Nếu chưa có EC2 thì chạy local và ghi rõ cấu hình máy.

Báo cáo `docs/implement/poc/AR-02.md`: thời gian, khuyến nghị số vCPU cho TEI và kích thước lô.

## Các bước thực hiện

1. Viết `tests/eval/poc_embedding.py`.
2. Chạy 3 lần, lấy trung vị.
3. Viết báo cáo.

## File cần tạo / sửa

- `backend/tests/eval/poc_embedding.py`
- `docs/implement/poc/AR-02.md`

## Tiêu chí hoàn thành

- [ ] Báo cáo kết luận đạt / không đạt ≤ 60 s, có khuyến nghị cấu hình.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- —

## Ngoài phạm vi task này

- Tối ưu chunker.

## Tham chiếu

- [SAD.md](../../design/SAD.md) AR-02
- [Blueprint_Design.md](../../design/Blueprint_Design.md) §3.8
