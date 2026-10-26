# T-304 — Runbook vận hành

| Thuộc tính | Giá trị |
|---|---|
| Story | — (hạng mục nền tảng) |
| Giai đoạn | Tuần ổn định (07/12 → 11/12/2026) |
| Loại | Hạ tầng / DevOps |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | TL |
| Phụ thuộc (phải xong trước) | [T-006](T-006-aws-environment.md), [T-103](T-103-admin-cli.md) |
| Mở khóa cho | [T-306](T-306-go-live.md) |
| Nhánh git | `feat/T-304-runbook` |
| Trạng thái | `To do` |

## Mục tiêu

Bất kỳ thành viên nào trong đội cũng vận hành được hệ thống trong thời gian pilot.

## Phạm vi & đặc tả

**`docs/implement/Runbook.md` gồm:**

1. Deploy (`deploy.sh <tag>`) và rollback (`rollback.sh`); quy tắc: **chạy `make eval` trước mỗi lần deploy**, deploy ngoài giờ làm việc.
2. Quản lý tài khoản bằng CLI (T-103): tạo, reset mật khẩu, vô hiệu hóa, mở khóa.
3. Xem log: CloudWatch Logs Insights — truy vấn mẫu theo `request_id`, theo lỗi 5xx, theo `document_id`.
4. Sự cố thường gặp và cách xử lý: TEI không chạy, Anthropic lỗi (kiểm tra status page, hạn mức chi tiêu), worker treo (xem job `running` lâu), đĩa đầy.
5. Truy vấn SQL số liệu tuần (thay cho US-021 / US-022) — xem bên dưới.
6. Sao lưu / khôi phục: khôi phục RDS bằng PITR; S3 versioning.
7. Danh bạ liên hệ: Tech lead, PO, IT, đầu mối AWS / Anthropic.

**Truy vấn SQL số liệu tuần:**

```sql
SELECT date_trunc('week', m.created_at) AS week,
       count(DISTINCT c.user_id) AS active_users,
       count(*) FILTER (WHERE m.role='user') AS questions,
       round(100.0*count(*) FILTER (WHERE m.state='not_found')
             / nullif(count(*) FILTER (WHERE m.role='assistant'),0),1) AS not_found_pct,
       percentile_cont(0.9) WITHIN GROUP (ORDER BY m.latency_ms)
             FILTER (WHERE m.role='assistant' AND m.state='complete') AS p90_latency_ms
FROM messages m JOIN conversations c ON c.id = m.conversation_id
GROUP BY 1 ORDER BY 1 DESC;
```

## Các bước thực hiện

1. Viết Runbook.
2. Một thành viên khác làm thử theo Runbook: deploy + rollback trên môi trường AWS.

## File cần tạo / sửa

- `docs/implement/Runbook.md`

## Tiêu chí hoàn thành

- [ ] Người không phải Tech lead deploy và rollback thành công chỉ bằng Runbook.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Diễn tập.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §4.2
- [Dev_Tasks.md](../Dev_Tasks.md) §5
