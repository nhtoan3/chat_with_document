# T-207 — SSE client trên frontend

| Thuộc tính | Giá trị |
|---|---|
| Story | [US-011 — Hỏi và nhận câu trả lời](../../requirements/User_Stories.md) |
| Giai đoạn | Sprint 2 (23/11 → 04/12/2026) |
| Loại | Frontend |
| Ước lượng | 1 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-007](T-007-frontend-shell.md) |
| Mở khóa cho | [T-206](T-206-chat-ui.md), [T-218](T-218-streaming-render.md) |
| Nhánh git | `feat/T-207-sse-client` |
| Trạng thái | `To do` |

## Mục tiêu

Hàm dùng chung đọc luồng SSE từ một request POST (`EventSource` chỉ hỗ trợ GET nên không dùng được).

## Phạm vi & đặc tả

**`shared/api/sse.ts`:**

```ts
type Handlers = { onMeta?(d): void; onDelta?(d): void; onCitation?(d): void;
                  onNotFound?(d): void; onDone?(d): void; onError?(d): void };
export async function streamQuestion(convId: string, question: string, h: Handlers, signal?: AbortSignal): Promise<void>
```

1. `fetch` POST, có header CSRF và `Accept: text/event-stream`. `!res.ok` → đọc problem+json → `throw new ApiError(code)`.
2. `res.body.getReader()` + `TextDecoder('utf-8')` → bộ đệm → tách theo `\n\n` → mỗi khối parse các dòng `event:` / `data:` (bỏ qua dòng bắt đầu bằng `:` — đó là ping).
3. Gọi handler tương ứng với `JSON.parse(data)`.
4. Stream kết thúc mà chưa nhận `done`, `not_found` hoặc `error` → ném `StreamInterruptedError` (dùng cho T-219).

## Các bước thực hiện

1. Viết hàm.
2. Viết unit test với `ReadableStream` giả lập (gồm trường hợp một event bị chia cắt giữa 2 chunk).

## File cần tạo / sửa

- `frontend/src/shared/api/sse.ts`
- `frontend/src/shared/api/sse.test.ts`

## Tiêu chí hoàn thành

- [ ] Parse đúng khi event bị chia cắt giữa các chunk; ký tự tiếng Việt nhiều byte không bị vỡ.
- [ ] Đạt Definition of Done chung ([User_Stories.md §9](../../requirements/User_Stories.md)): code review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Vitest.

## Tham chiếu

- [SAD.md](../../design/SAD.md) §2.1 (giao thức), §2.4 (hợp đồng SSE)
