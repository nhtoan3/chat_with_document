# ADR-012: Một môi trường AWS, log JSON, CI tối giản

> Version 0.1 · Trạng thái tài liệu: `Draft` · 2026-11-02 · Chưa được review/duyệt
> Nguồn: `docs/04-design/SAD.md` "Phạm vi kiến trúc cho MVP", §5; `docs/05-development/Implement_plan.md` §1; `infra/README.md`; `.github/workflows/`

## Status

`Accepted (v0.2)`, ghi nguyên văn theo SAD §5. Repo không có biên bản duyệt riêng cho ADR này.

## Context

SAD v0.2 thu hẹp kiến trúc để rút ngắn thời gian ra mắt. Lý do chi tiết hơn: [TBD].

## Decision

| Hạng mục | MVP v0.2 (SAD) | Hiện trạng v0.4 |
|---|---|---|
| Môi trường | Một môi trường AWS + local | Đúng (`infra/README.md`) |
| Observability | Log JSON (`structlog`) → CloudWatch; độ trễ trong `messages` | Log JSON → CloudWatch `/cwd/prod`; độ trễ trong **`qa_log.latency_ms`** |
| CI | lint, test, `pip-audit`, gitleaks | lint, test, build. **Không có `pip-audit`, gitleaks** trong workflow; Plan v0.4 §1 lược bỏ quét bảo mật trong CI |
| Golden eval | Bắt buộc trước mỗi lần deploy | `infra/README.md` §4 yêu cầu trước mỗi lần deploy lên môi trường đang có người dùng pilot; đây là quy tắc thủ công |

## Consequences

- Không có staging: thay đổi đi thẳng lên môi trường duy nhất, nên rollback dựa vào `infra/rollback.sh`.
- Không có metric, trace hay dashboard; số liệu pilot lấy bằng SQL trên `qa_log`.
- Lỗ hổng phụ thuộc và khóa lộ không được CI phát hiện tự động.

## Rejected alternatives

| Phương án | Lý do |
|---|---|
| Staging riêng, Terraform, stack OTel / Grafana | Để giai đoạn 2 (SAD §5) |
