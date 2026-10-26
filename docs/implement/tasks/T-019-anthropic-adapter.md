# T-019 — Adapter gọi Claude (Anthropic API)

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | F2 — Hỏi đáp AI |
| Giai đoạn | Sprint 1 — Xử lý PDF + Hỏi đáp AI (09/11 → 20/11/2026) |
| Loại | Backend |
| Ước lượng | 1,5 ngày |
| Phụ trách đề xuất | BE2 |
| Phụ thuộc (phải xong trước) | [T-018](T-018-system-prompt.md) |
| Mở khóa cho | [T-020](T-020-ask-api.md) |
| Nhánh git | `feat/T-019-anthropic-adapter` |
| Trạng thái | `To do` |

## Mục tiêu

Gọi Claude và nhận câu trả lời hoàn chỉnh (không streaming).

## Phạm vi & đặc tả

**Port:** `LLMPort.answer(question, chunks) -> LLMResult(text, input_tokens, output_tokens)`; lỗi → `LLMUnavailable`.

**Adapter** (`qa/adapters/anthropic_llm.py`):

```python
client = anthropic.AsyncAnthropic(max_retries=2, timeout=settings.LLM_TIMEOUT_S)
resp = await client.messages.create(
    model=settings.LLM_MODEL,              # claude-opus-5-5
    max_tokens=2048,
    output_config={"effort": "low"},
    system=SYSTEM_PROMPT,
    messages=[{"role": "user", "content": build_context(chunks, question)}])
text = "".join(b.text for b in resp.content if b.type == "text")
```

**Xử lý lỗi** (bắt từ lớp cụ thể tới lớp chung):

| Trường hợp | Kết quả |
|---|---|
| `RateLimitError`, `APIStatusError` ≥ 500, `APIConnectionError`, timeout | `LLMUnavailable` |
| `stop_reason == "refusal"` | Trả câu "Không tìm thấy thông tin này trong tài liệu." |
| `stop_reason == "max_tokens"` | Ghi log `warning`, vẫn trả kết quả |

⚠ **Trước khi code:** đối chiếu tài liệu Anthropic Python SDK về `output_config` / `effort` và cấu hình thinking mặc định của model đang dùng.

Viết `FakeLLM` để dùng trong test.

## Các bước thực hiện

1. Viết port, adapter, `FakeLLM`.
2. Gọi thử một lần với tài liệu mẫu.
3. Viết test.

## File cần tạo / sửa

- `backend/app/modules/qa/adapters/anthropic_llm.py`
- `backend/tests/fakes/fake_llm.py`

## Tiêu chí hoàn thành

- [ ] Lỗi 500 / 529 giả lập → `LLMUnavailable`.
- [ ] Log có model, token, latency — không có nội dung.
- [ ] Code đã được review, CI xanh, đã deploy lên môi trường AWS.

## Kiểm thử

- Unit với client giả lập; gọi thật thủ công.

## Ngoài phạm vi task này

- Streaming, Citations, fallback (đã lược bỏ).

## Tham chiếu

- [SAD.md](../../design/SAD.md) ADR-005
