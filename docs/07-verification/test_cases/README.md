# Test case — Chat với tài liệu (MVP v0.4)

> Tách từ [Test_Plan.md](../Test_Plan.md) (TP-CWD-001 v0.2). Mỗi file `<ID>.md` là **một test case** để agent (hoặc người) thực hiện trên **localhost** và tạo bằng chứng.
> Gồm **77 test case** chạy được trên localhost. Các test chỉ chạy được trên AWS hoặc cần con người nằm ở §7.

## 1. Quy ước bắt buộc cho mọi test case

| Mục | Quy ước |
|---|---|
| Ứng dụng kiểm thử | Chỉ localhost: web `http://localhost:5173`, API `http://localhost:8000`, TEI `http://localhost:8080`, S3Mock `http://localhost:9090`, PostgreSQL `localhost:5432`. Không gọi môi trường AWS |
| Thư mục artifact | `./test_reports/<ID>/` ở gốc repo, tên thư mục **đúng bằng mã test case** (ví dụ `./test_reports/E2E-001/`). Mọi file của test case chỉ nằm trong thư mục này |
| Video | Quay toàn bộ quá trình test → `video.webm` (phiên thứ hai trở đi: `video-02.webm`, …) |
| Ảnh chụp màn hình | Ít nhất 1 ảnh cho mỗi bước có 📸 → `screenshots/NN-<mô-tả>.png` (đánh số tự động) |
| Báo cáo | `report.md` theo mẫu §5, kết luận ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn |
| Chạy lại | Xóa thư mục cũ trước: `rm -rf test_reports/<ID>` |
| Mã ứng dụng | Không sửa mã ứng dụng để test đạt. Lỗi phát hiện ghi vào báo cáo (mức độ theo Test_Plan §6.4) |
| Dữ liệu | Chỉ dùng fixture giả lập trong `backend/tests/fixtures/pdfs/` hoặc dữ liệu sinh ra; không dùng tài liệu thật của khách hàng |
| Chạy song song | **Không** chạy song song: nhiều test dọn dữ liệu (`reset_data`) hoặc dừng container (`tei`, `s3`, `postgres`, `worker`, `api`) |

## 2. Chuẩn bị môi trường (một lần)

```bash
make venv                       # backend virtualenv (Python 3.12)
(cd frontend && npm ci)         # có Playwright 1.64.1 (devDependency)
npx --prefix frontend playwright install chromium   # chỉ khi máy chưa có trình duyệt Chromium của Playwright
make dev                        # postgres, s3, tei, api, worker x2, web — lần đầu TEI tải ~2,3 GB
make fixtures                   # sinh lại PDF fixture
# Test cần Claude thật: thêm ANTHROPIC_API_KEY vào .env rồi `docker compose up -d api`
bash -c 'source frontend/e2e/lib.sh && check_stack'   # phải in "Stack OK"
```

**Thư viện shell dùng chung** `frontend/e2e/lib.sh` (nạp bằng `source frontend/e2e/lib.sh`):

| Hàm | Tác dụng |
|---|---|
| `check_stack` | Kiểm API và web localhost phản hồi |
| `reset_data` | Xóa toàn bộ `documents`, `ingestion_jobs`, `chunks`, `qa_log` |
| `upload <tệp>...` | `POST /api/v1/documents`, in body + mã HTTP |
| `seed_samples` | Tải 3 PDF mẫu |
| `wait_idle [giây]` | Chờ tới khi không còn tài liệu đang xử lý |
| `docs`, `counts` | Xem danh sách / số đếm tài liệu |
| `ask "<câu hỏi>"` | `POST /api/v1/ask`, in body, mã HTTP, thời gian |
| `psql_q "<SQL>"` | Chạy SQL trên PostgreSQL local |
| `make_pdf <kind> <out>` | Sinh tệp test: `big21mb`, `big20mb`, `pages301`, `pages50` |
| Biến | `API_URL`, `WEB_URL`, `FIXTURES`, `DATA_DIR` (= `test_reports/<ID>/data`), `COMPOSE` |

## 3. Cấu trúc artifact của một test case

```
test_reports/
└── E2E-001/                    # tên thư mục = mã test case
    ├── report.md               # báo cáo kết quả (bắt buộc)
    ├── video.webm              # video toàn bộ quá trình test (bắt buộc)
    ├── screenshots/            # ảnh bằng chứng, đánh số theo thứ tự (bắt buộc)
    │   ├── 01-trang-tai-lieu-trong.png
    │   └── 02-...png
    ├── logs/                   # output lệnh, browser-console.log, checks.json, CSV eval…
    ├── data/                   # tệp sinh ra cho test (PDF 21 MB, override compose…)
    ├── steps.sh                # script CLI đã chạy (test CLI)
    └── E2E-001.mjs             # script Playwright đã chạy (test UI)
```

## 4. Công cụ ghi bằng chứng

### 4.1 Test CLI — `frontend/e2e/run-cli.mjs`

```bash
# 1. Chép khối "Script gợi ý" của test case vào test_reports/<ID>/steps.sh
# 2. Chạy từ gốc repo:
node frontend/e2e/run-cli.mjs INT-004 test_reports/INT-004/steps.sh
```

Công cụ chạy `steps.sh` bằng bash, hiển thị output trực tiếp trong một trang dạng terminal và **quay video** trang đó. Mỗi dòng bắt đầu bằng `### ` là một bước: khi bước kết thúc, công cụ **chụp ảnh**, và chụp thêm một ảnh ở cuối. Log đầy đủ lưu ở `logs/steps.log`. Mã thoát của công cụ bằng mã thoát của script. Biến `TEST_ID` và `TEST_DIR` được truyền vào script.

### 4.2 Test UI — `frontend/e2e/evidence.mjs`

`startEvidence('<ID>')` mở Chromium có quay video và trả về `{ page, caption, shot, finish }`:

- `caption(text)` hiện tên bước trong video (tự ẩn khi chụp ảnh);
- `shot(name)` chụp ảnh toàn trang vào `screenshots/NN-<name>.png`;
- `finish()` đóng trình duyệt, lưu `video.webm` và `logs/browser-console.log` (gồm cả các hộp thoại `alert`).

Ví dụ đầy đủ cho E2E-004, lưu tại `test_reports/E2E-004/E2E-004.mjs` và chạy bằng `node test_reports/E2E-004/E2E-004.mjs` từ gốc repo:

```js
import { execSync } from 'node:child_process'
import fs from 'node:fs'
import path from 'node:path'
import { startEvidence, WEB_URL, REPO_ROOT } from '../../frontend/e2e/evidence.mjs'

// Điều kiện tiên quyết: stack chạy, không có tài liệu nào
execSync(`bash -c 'source frontend/e2e/lib.sh && check_stack && reset_data'`, { cwd: REPO_ROOT, stdio: 'inherit' })

const ev = await startEvidence('E2E-004')
const { page } = ev
const checks = []
const check = (step, ok, detail) => checks.push({ step, ok, detail })
try {
  await page.goto(`${WEB_URL}/`)
  await ev.caption('Bước 1: mở trang gốc → chuyển tới /ask')
  await page.waitForURL('**/ask')
  check(1, page.url().endsWith('/ask'), page.url())
  await ev.shot('chuyen-toi-ask')

  await ev.caption('Bước 2: ô nhập và nút Gửi bị khóa')
  await page.getByText('Chưa có tài liệu nào ở trạng thái Sẵn sàng', { exact: false }).waitFor()
  const locked = (await page.locator('textarea').isDisabled()) &&
                 (await page.getByRole('button', { name: 'Gửi câu hỏi' }).isDisabled())
  check(2, locked, 'textarea và nút Gửi bị vô hiệu')
  await ev.shot('o-nhap-bi-khoa')

  await ev.caption('Bước 3: bấm "Tải lên tài liệu"')
  await page.getByRole('link', { name: 'Tải lên tài liệu' }).click()
  await page.waitForURL('**/documents')
  check(3, page.url().endsWith('/documents'), page.url())
  await ev.shot('trang-tai-lieu')
} catch (e) {
  check('lỗi', false, String(e))
  await ev.shot('loi').catch(() => {})
} finally {
  const { dir } = await ev.finish()
  fs.writeFileSync(path.join(dir, 'logs', 'checks.json'), JSON.stringify(checks, null, 2))
  console.table(checks)
}
```

**Cách gọn hơn:** `frontend/e2e/runner.mjs` → `runTest({ id, title, setup, cleanup, steps: [{ action, expect, run }] })` lo quay video, chụp ảnh sau mỗi bước, ghi `logs/checks.json` và **tự sinh `report.md`**. Hàm `mockAsk(page, [...])` dùng để giả lập `/api/v1/ask`. Xem các script mẫu `test_reports/E2E-00*/E2E-00*.mjs`.

**Hiển thị trình duyệt:** mặc định chạy nền (headless), video vẫn được quay. Đặt `HEADED=1` để mở cửa sổ Chromium, `SLOWMO=300` để chạy chậm, ví dụ `HEADED=1 SLOWMO=300 node test_reports/E2E-001/E2E-001.mjs`.

Mẹo:
- **Tải tệp:** `page.locator('input[type=file]').setInputFiles([...])`.
- **Giả lập API:** `page.route('**/api/v1/ask', r => r.fulfill({ status: 503, contentType: 'application/problem+json', body: JSON.stringify({...}) }))`.
- **Đếm request:** `page.on('request', r => r.url().includes('/api/v1/documents') && r.method() === 'POST' && n++)`.
- **Kết hợp lệnh shell:** dùng `execSync` như ví dụ. Output lệnh nên ghi vào `logs/`.

## 5. Mẫu báo cáo (`report.md`)

```markdown
# Báo cáo kiểm thử — <ID>: <tên test case>

| Mục | Giá trị |
|---|---|
| Test case | [<ID>](../../docs/07-verification/test_cases/<ID>.md) |
| Kết luận | ✅ Đạt / ❌ Không đạt / ⛔ Bị chặn |
| Thời gian chạy | YYYY-MM-DD HH:MM → HH:MM (UTC+7) |
| Người / agent thực hiện | |
| Commit | `<git rev-parse --short HEAD>` (+ "có thay đổi chưa commit" nếu `git status` không sạch) |
| Môi trường | localhost · web http://localhost:5173 · API http://localhost:8000 · <OS> · Docker <phiên bản> · ANTHROPIC_API_KEY: có / không |

## Kết quả từng bước

| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |
|---|---|---|---|---|---|
| 1 | … | … | … | ✅ / ❌ | [01-….png](screenshots/01-….png) |

## Bằng chứng

- Video: [video.webm](video.webm)
- Ảnh:

  ![Bước 1](screenshots/01-….png)

- Log: [logs/steps.log](logs/steps.log)

## Lỗi phát hiện

| # | Mô tả | Mức độ (Blocker / Critical / Major / Minor) | Bước | Bằng chứng |
|---|---|---|---|---|

## Ghi chú và sai lệch so với test case
```

## 6. Danh sách test case

### Unit test (27)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [UT-001](UT-001.md) | Chunker: trang dài được chia trong giới hạn và có chồng lấp | P0 | ADR-006 | CLI |
| [UT-002](UT-002.md) | Chunker: trang ngắn được gộp với trang sau | P0 | ADR-006 | CLI |
| [UT-003](UT-003.md) | Chunker: chunk không trải qua hai trang thường | P0 | ADR-006 | CLI |
| [UT-004](UT-004.md) | Chunker: bỏ trang rỗng, văn bản embed có tiền tố | P0 | ADR-006 | CLI |
| [UT-005](UT-005.md) | Trích xuất PDF giữ trang và dấu tiếng Việt (NFC) | P0 | REQ-VN-01 | CLI |
| [UT-006](UT-006.md) | Trích xuất PDF từ chối tệp mã hóa, scan, hỏng | P0 | US-007 / FR-007 | CLI |
| [UT-007](UT-007.md) | Trích xuất PDF từ chối tệp quá 300 trang | P0 | US-007 / FR-007 | CLI |
| [UT-008](UT-008.md) | AppError được render thành problem+json | P0 | API-CONTRACT | CLI |
| [UT-009](UT-009.md) | Chuẩn hóa tên tệp: bỏ đường dẫn, giới hạn độ dài | P1 | REQ-FN-01 | CLI |
| [UT-010](UT-010.md) | Backoff thử lại 10 / 40 / 160 giây | P0 | NFR-021 | CLI |
| [UT-011](UT-011.md) | Use case hỏi đáp: kết quả thành công | P0 | US-011 / BR-006 | CLI |
| [UT-012](UT-012.md) | Use case hỏi đáp: câu hỏi không hợp lệ | P0 | AC-US-011-3, 4 | CLI |
| [UT-013](UT-013.md) | Use case hỏi đáp: trim câu hỏi, cho phép đúng 2000 ký tự | P0 | AC-US-011-3, 4 | CLI |
| [UT-014](UT-014.md) | Use case hỏi đáp: không có tài liệu Sẵn sàng thì không gọi embedder | P0 | AC-US-008-4 | CLI |
| [UT-015](UT-015.md) | Use case hỏi đáp: lỗi dịch vụ ngoài thành kết quả lỗi | P0 | AC-US-011-8 | CLI |
| [UT-016](UT-016.md) | Prompt chứa đủ quy tắc bắt buộc và định dạng ngữ cảnh | P0 | BRU-001, US-015 | CLI |
| [UT-017](UT-017.md) | Adapter Claude: lỗi API được ánh xạ thành LLM unavailable | P0 | AC-US-011-8 | CLI |
| [UT-018](UT-018.md) | Adapter Claude: TypeError không liên quan không bị nuốt | P0 | AC-US-011-8 | CLI |
| [UT-019](UT-019.md) | Adapter Claude: ghép các text block, bỏ thinking | P0 | US-011 | CLI |
| [UT-020](UT-020.md) | Adapter Claude: refusal trả câu "không tìm thấy" | P0 | BRU-001 / US-014 | CLI |
| [UT-021](UT-021.md) | Chấm điểm eval: tỷ lệ và câu chưa chấm | P0 | KR2.1 | CLI |
| [UT-022](UT-022.md) | Chấm điểm eval: nhận diện câu "không tìm thấy" | P0 | KR2.3 | CLI |
| [UT-023](UT-023.md) | Kiểm tra tệp phía client (số lượng, loại, dung lượng) | P0 | US-005 / BR-001, FR-007 | CLI |
| [UT-024](UT-024.md) | Kiểm tra câu hỏi phía client (rỗng, 2000 / 2001 ký tự) | P0 | AC-US-011-3, 4 | CLI |
| [UT-025](UT-025.md) | Render Markdown an toàn (chống XSS) | P0 | UXC-09 | CLI |
| [UT-026](UT-026.md) | API client: tiền tố, problem+json, lỗi mạng, thông điệp tiếng Việt | P0 | API-CONTRACT, US-015 | CLI |
| [UT-027](UT-027.md) | Mọi mã lỗi đều có thông điệp tiếng Việt trong vi.json | P1 | API-CONTRACT, quy tắc AGENTS.md | CLI |

### Integration / API (22)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [INT-001](INT-001.md) | Tải lên 3 PDF hợp lệ rồi xử lý tới Sẵn sàng | P0 | US-005 / BR-001, ADR-006 | CLI |
| [INT-002](INT-002.md) | Tải 11 tệp: từ chối cả lô | P0 | US-005 / BR-001 | CLI |
| [INT-003](INT-003.md) | Tải 0 tệp: trả lỗi too_many_files | P1 | US-005 / BR-001 | CLI |
| [INT-004](INT-004.md) | Lô trộn: tệp lỗi không chặn tệp hợp lệ | P0 | AC-US-005-5, US-007 | CLI |
| [INT-005](INT-005.md) | Trùng tên tài liệu đã có | P1 | EC-08 (rút gọn) | CLI |
| [INT-006](INT-006.md) | Bộ tài liệu đạt giới hạn 50 | P1 | NFR-006 / EC-14 | CLI |
| [INT-007](INT-007.md) | PDF lỗi được đánh dấu failed với mã tương ứng | P0 | US-007 / FR-007, NFR-021 | CLI |
| [INT-008](INT-008.md) | Lỗi tạm thời: thử lại 3 lần rồi transient_exhausted | P0 | NFR-021 | CLI |
| [INT-009](INT-009.md) | Hai worker không lấy trùng một job | P0 | ADR-010 | CLI |
| [INT-010](INT-010.md) | Thu hồi job treo (running quá hạn) | P0 | ADR-010 | CLI |
| [INT-011](INT-011.md) | GET /documents: danh sách, counts, thứ tự | P1 | US-006 / FR-006 | CLI |
| [INT-012](INT-012.md) | Lỗi lưu trữ S3 khi tải lên → 502 storage_error | P1 | API-CONTRACT, F1.1 | CLI |
| [INT-013](INT-013.md) | Truy xuất xếp hạng đúng đoạn và bỏ tài liệu chưa Sẵn sàng | P0 | US-008 / BR-002 | CLI |
| [INT-014](INT-014.md) | Hỏi đáp thành công và qa_log không chứa nội dung | P0 | US-011 / BR-006, PRD §6.2 / CN-06 | CLI |
| [INT-015](INT-015.md) | Câu hỏi rỗng / quá dài → 422 question_invalid | P0 | AC-US-011-3, 4 / EC-12 | CLI |
| [INT-016](INT-016.md) | Body không hợp lệ → 422 question_invalid (problem+json) | P1 | AC-US-011-3, API-CONTRACT | CLI |
| [INT-017](INT-017.md) | Không có tài liệu Sẵn sàng → 409 no_documents | P0 | AC-US-008-4 / EC-01 | CLI |
| [INT-018](INT-018.md) | LLM lỗi → 503 ai_unavailable và qa_log status error | P0 | AC-US-011-8 / EC-06 | CLI |
| [INT-019](INT-019.md) | TEI lỗi khi hỏi → 503 ai_unavailable | P1 | AC-US-011-8 / EC-06 | CLI |
| [INT-020](INT-020.md) | Lỗi không lường trước → 500 internal_error, không lộ stack trace | P1 | API-CONTRACT | CLI |
| [INT-021](INT-021.md) | /healthz trả 200 | P0 | OPS-DEPLOY | CLI |
| [INT-022](INT-022.md) | Gọi Claude thật với tài liệu mẫu (live) | P1 | US-011, US-015, BRU-001 | CLI |

### E2E / hệ thống (9)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [E2E-001](E2E-001.md) | Tải lên PDF và theo dõi trạng thái tới Sẵn sàng | P0 | US-005, US-006, US-007 | UI |
| [E2E-002](E2E-002.md) | Tệp lỗi sau xử lý hiển thị đúng lý do | P0 | US-007 / FR-007, NFR-021 | UI |
| [E2E-003](E2E-003.md) | Kiểm tra tệp phía client (> 10 tệp, > 20 MB) | P1 | US-005 / BR-001 | UI |
| [E2E-004](E2E-004.md) | Chưa có tài liệu Sẵn sàng: khóa ô hỏi | P0 | AC-US-008-4 / EC-01 | UI |
| [E2E-005](E2E-005.md) | Hỏi và nhận câu trả lời | P0 | US-011, US-015 | UI |
| [E2E-006](E2E-006.md) | Kiểm tra ô nhập câu hỏi | P1 | AC-US-011-3, 4 / EC-12 | UI |
| [E2E-007](E2E-007.md) | Lỗi AI và nút Hỏi lại | P0 | AC-US-011-8 / EC-06 | UI |
| [E2E-008](E2E-008.md) | XSS trong câu trả lời không được thực thi | P0 | UXC-09 | UI |
| [E2E-009](E2E-009.md) | Lịch sử hỏi đáp chỉ giữ trong trang | P2 | T-021 (đặc tả lịch sử) | UI |

### Đánh giá chất lượng AI (5)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [EVAL-001](EVAL-001.md) | Tỷ lệ trả lời đúng câu positive ≥ 80% | P0 | KR2.1, AC-US-011-1 | CLI |
| [EVAL-002](EVAL-002.md) | Tỷ lệ "không tìm thấy" câu negative ≥ 90% | P0 | KR2.3, AC-US-014-1 | CLI |
| [EVAL-003](EVAL-003.md) | Không bịa ở câu negative | P0 | BRU-001, AC-US-014-1 | CLI |
| [EVAL-004](EVAL-004.md) | Mọi câu trả lời bằng tiếng Việt | P0 | US-015 | CLI |
| [EVAL-005](EVAL-005.md) | Độ trễ p90 trên golden set | P1 | NFR-001 | CLI |

### Hiệu năng (3)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [PERF-001](PERF-001.md) | PDF văn bản 50 trang Sẵn sàng ≤ 60 giây | P1 | NFR-003 | CLI |
| [PERF-003](PERF-003.md) | Tải lô 10 × 20 MB: RAM api tăng ≤ 100 MB | P1 | US-005, F1.1 | CLI |
| [PERF-004](PERF-004.md) | AI không phản hồi: báo lỗi trong ≤ 30 giây | P1 | NFR-020, EC-06, AC-US-011-8 | CLI + UI |

### Bảo mật (theo tiêu chí task) (3)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [SEC-004](SEC-004.md) | Chống XSS trong câu trả lời | P0 | UXC-09 | CLI + UI |
| [SEC-005](SEC-005.md) | An toàn khi tải tệp (tên tệp, loại tệp, kích thước) | P1 | REQ-FN-01, F1.1 | CLI |
| [SEC-006](SEC-006.md) | Không log nội dung câu hỏi, câu trả lời, tài liệu | P0 | CN-06, PRD §6.2 | CLI |

### Giao diện (3)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [UI-001](UI-001.md) | Giao diện khớp thiết kế HTML (bản tối giản) | P1 | T-015, T-021 | UI |
| [UI-002](UI-002.md) | Không có chuỗi giao diện viết cứng trong TSX | P1 | US-015, quy tắc AGENTS.md | CLI |
| [UI-003](UI-003.md) | Badge trạng thái có icon và chữ | P1 | T-015, US-006 | UI |

### Vận hành (5)

| Mã | Tên | Ưu tiên | Yêu cầu | Bằng chứng |
|---|---|---|---|---|
| [OPS-001](OPS-001.md) | make dev dựng đủ stack healthy | P1 | OPS-LOCAL | CLI |
| [OPS-002](OPS-002.md) | make seed nạp 3 PDF mẫu tới Sẵn sàng | P2 | OPS-LOCAL | CLI |
| [OPS-007](OPS-007.md) | Khởi động lại worker khi đang xử lý: job được thu hồi | P1 | ADR-010 | CLI |
| [OPS-008](OPS-008.md) | Thiếu ANTHROPIC_API_KEY: /ask 503, phần còn lại vẫn chạy | P1 | AC-US-011-8 | CLI |
| [OPS-009](OPS-009.md) | Truy vấn số liệu pilot chạy được | P2 | PRD §6.2 | CLI |

## 7. Test case không chạy được trên localhost

Các test case dưới đây có trong Test_Plan nhưng **không có file ở đây**, vì cần môi trường AWS, GitHub hoặc người dùng thật. Chúng được thực hiện theo Test_Plan §6.3 trong tuần ổn định.

| Mã | Lý do |
|---|---|
| PERF-002 | Đo p90 thời gian trả lời trên AWS với bộ 50 tài liệu (bản tham khảo local: EVAL-005) |
| SEC-001 | Giới hạn IP / VPN của ALB, cần thử từ mạng ngoài |
| SEC-002 | TLS / ACM trên ALB |
| SEC-003 | SSE-KMS của S3, mã hóa RDS |
| OPS-003, OPS-004 | CI trên GitHub Actions, đẩy image lên ECR |
| OPS-005, OPS-006 | `infra/deploy.sh`, `infra/rollback.sh` trên EC2 |
| UAT-001 … UAT-006 | Do đại diện BD thực hiện trên AWS (biên bản `docs/implement/evidence/UAT.md`) |

## 8. Thứ tự chạy gợi ý

1. **OPS-001** để xác nhận stack, sau đó **INT-021**.
2. Unit test **UT-001 … UT-027** (không phụ thuộc dữ liệu).
3. **INT-*** và **SEC-005**, **SEC-006**, **OPS-002**, **OPS-009**.
4. **E2E-***, **UI-***, **SEC-004**.
5. Test dừng hoặc khởi động lại container, chạy sau cùng, từng cái một: **INT-008, INT-012, INT-018, INT-019, INT-020, OPS-007, OPS-008, PERF-004**.
6. Test cần `ANTHROPIC_API_KEY`: **INT-014** (bước 4), **INT-022**, **EVAL-001 … 005**, **E2E-005** (chạy với Claude thật).
7. **PERF-001**, **PERF-003**.
