# T-221 — Cấu hình Nginx và ALB cho SSE

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-016 — Câu trả lời hiện dần](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 0,25 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-006](T-006-aws-environment.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-221-sse-proxy-config` |
| Trạng thái | `To do` |

## Mục tiêu

Proxy không đệm và không cắt luồng SSE.

## Phạm vi & đặc tả

**`infra/nginx.conf`:**

```nginx
location /api/v1/conversations/ {
    proxy_pass http://api:8000;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_buffering off;
    proxy_cache off;
    proxy_read_timeout 120s;
}
```

**ALB:** idle timeout 120 s (đã cấu hình ở T-006, kiểm tra lại).

## Các bước thực hiện

1. Cập nhật cấu hình.
2. Deploy.
3. Kiểm tra bằng `curl -N`.

## File cần tạo / sửa

- `infra/nginx.conf`

## Tiêu chí hoàn thành

- [ ] `curl -N` qua domain thật nhận từng event ngay khi server phát (không bị dồn tới cuối).
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Thủ công bằng `curl -N`.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §2.4 (ping 15 s, ALB 120 s)
