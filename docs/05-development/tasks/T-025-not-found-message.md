# T-025 — Bổ sung thông điệp `not_found` và test đồng bộ mã lỗi ↔ `vi.json`

| Thuộc tính | Giá trị |
|---|---|
| Tính năng | Nền tảng (hợp đồng lỗi API) |
| Giai đoạn | Tuần ổn định & go-live (23/11 → 27/11/2026) |
| Loại | Backend + Frontend |
| Ước lượng | 0,5 ngày |
| Phụ trách đề xuất | FE |
| Phụ thuộc (phải xong trước) | [T-005](T-005-platform-kernel.md), [T-007](T-007-frontend-shell.md) |
| Mở khóa cho | — |
| Nhánh git | `feat/T-025-not-found-message` |
| Trạng thái | `To do` |
| Nguồn | DEF-04 trong `docs/07-verification/test-report.md`; test case UT-027 ❌ |

## Mục tiêu

Mọi mã lỗi backend có thể trả cho giao diện đều có thông điệp tiếng Việt, và có test tự động giữ hai bên đồng bộ.

## Phạm vi & đặc tả

- `backend/app/platform/errors.py::ERRORS` có `not_found` (404) nhưng `frontend/src/shared/i18n/vi.json` (`errors.*`) và `frontend/src/shared/api/errors.ts::KNOWN` không có. Trái quy tắc `AGENTS.md`: "Thêm mã mới thì thêm cả thông điệp tiếng Việt trong `vi.json`".
- Quyết định đã chốt: **giữ** `not_found` trong `ERRORS` (dùng cho 404 về sau) và **thêm** thông điệp; không xóa mã.
- Thêm một test tự động so sánh tập khóa `ERRORS` (backend) với `errors.*` trong `vi.json`, để lỗi này không tái diễn. Vị trí: unit test backend đọc `vi.json` từ repo (`backend/tests/unit/test_error_codes_i18n.py`), hoặc vitest đọc `ERRORS` qua một file JSON xuất ra; chọn cách nào không cần build chéo. Năm mã của worker (`encrypted_pdf`, `no_text_layer`, `too_many_pages`, `corrupted`, `transient_exhausted`) không nằm trong `ERRORS`, test phải nêu rõ chúng là tập riêng và vẫn phải có trong `vi.json`.

## Các bước thực hiện

1. Viết test đồng bộ trước; xác nhận nó **đỏ** vì thiếu `not_found`.
2. Thêm `"not_found": "Không tìm thấy."` (hoặc câu tương đương, ngắn) vào `vi.json` và `not_found` vào `KNOWN` trong `errors.ts`.
3. Chạy `make lint`, `make test`; chạy lại test case UT-027 theo `docs/07-verification/test_cases/UT-027.md`, ghi bằng chứng vào `test_reports/UT-027/`.
4. Cập nhật `docs/05-development/traceability.md` (dòng "API contract") và `docs/sdlc-state.md` (DEF-04).

## File cần tạo / sửa

- `frontend/src/shared/i18n/vi.json`
- `frontend/src/shared/api/errors.ts`
- `backend/tests/unit/test_error_codes_i18n.py` (mới) hoặc tương đương phía frontend
- `docs/05-development/traceability.md`, `docs/sdlc-state.md`

## Tiêu chí hoàn thành

- [ ] AC-1: Mọi khóa trong `ERRORS` đều có `errors.<khóa>` trong `vi.json`; test tự động kiểm điều này và đang xanh.
- [ ] AC-2: `messageForCode('not_found')` trả thông điệp tiếng Việt, không rơi về `unknown`.
- [ ] AC-3: UT-027 chạy lại cho kết quả ✅, bằng chứng trong `test_reports/UT-027/`.
- [ ] AC-4: `make lint` và `make test` xanh.
- [ ] Code đã được review, CI xanh.

## Kiểm thử

- Unit: test đồng bộ mới; `frontend/src/shared/api/client.test.ts` giữ nguyên.
- Test case: UT-027.

## Ngoài phạm vi task này

- Chuyển 404/405 mặc định của Starlette sang problem+json (ghi nhận trong `docs/04-design/openapi.md` §5, cần task riêng).

## Tham chiếu

- `docs/07-verification/test-report.md` — DEF-04
- `docs/04-design/openapi.md` — mục lỗi
- `AGENTS.md` — quy tắc lỗi API
