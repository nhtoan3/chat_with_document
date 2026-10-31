// E2E-007 — Lỗi AI và nút Hỏi lại
// Chạy từ gốc repo: node test_reports/E2E-007/E2E-007.mjs
import { runTest, mockAsk, WEB_URL } from '../../frontend/e2e/runner.mjs'

const PROBLEM_503 = {
  status: 503,
  contentType: 'application/problem+json',
  delayMs: 1500,
  body: { type: 'about:blank', title: 'AI service unavailable', status: 503, code: 'ai_unavailable' },
}
const OK = { delayMs: 1000, body: { answer: 'Câu trả lời sau khi hỏi lại.', latency_ms: 1200 } }
const NGINX_504 = { status: 504, contentType: 'text/html', body: '<html><body><h1>504 Gateway Time-out</h1></body></html>' }
let calls = []

await runTest({
  id: 'E2E-007',
  title: 'Lỗi AI và nút Hỏi lại',
  setup: 'check_stack && reset_data && seed_samples && wait_idle 300',
  cleanup: 'reset_data',
  notes: ['`/api/v1/ask` được giả lập: lần 1 trả 503 `ai_unavailable` (problem+json), lần 2 trả 200; bước 4 trả 504 HTML giống Nginx timeout.'],
  steps: [
    {
      action: 'Mở /ask, gửi "Mức phạt khi chậm thanh toán là bao nhiêu?"',
      expect: 'Spinner "Đang tìm câu trả lời…"',
      run: async ({ page }) => {
        calls = await mockAsk(page, [PROBLEM_503, OK, NGINX_504])
        await page.goto(`${WEB_URL}/ask`)
        await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        await page.locator('textarea#question').fill('Mức phạt khi chậm thanh toán là bao nhiêu?')
        await page.locator('textarea#question').press('Enter')
        await page.locator('.thinking').waitFor({ timeout: 1500 })
        return { ok: true, actual: `Spinner "${(await page.locator('.thinking').innerText()).split('\n')[0]}" hiển thị` }
      },
    },
    {
      action: 'Quan sát phản hồi lỗi',
      expect: '"Hệ thống đang bận, vui lòng thử lại." + "Câu hỏi của bạn không bị mất."; nút "Hỏi lại"; không có chữ kỹ thuật',
      run: async ({ page }) => {
        const body = page.locator('.msg-ai .body.error').last()
        await body.waitFor({ timeout: 10000 })
        const text = (await body.innerText()).replace(/\s+/g, ' ').trim()
        const retry = await body.getByRole('button', { name: 'Hỏi lại' }).count()
        const tech = /503|ai_unavailable|AI service unavailable|problem/i.test(text)
        return {
          ok: text.includes('Hệ thống đang bận, vui lòng thử lại.') && text.includes('Câu hỏi của bạn không bị mất.') && retry === 1 && !tech,
          actual: `Nội dung: "${text}"; nút Hỏi lại: ${retry}; chữ kỹ thuật: ${tech ? 'có' : 'không'}`,
        }
      },
    },
    {
      action: 'Bấm "Hỏi lại"',
      expect: 'Hiện "Câu trả lời sau khi hỏi lại." kèm nhãn AI; tổng 2 request',
      run: async ({ page }) => {
        await page.getByRole('button', { name: 'Hỏi lại' }).click()
        const ans = page.locator('.msg-ai .answer').last()
        await ans.waitFor({ timeout: 10000 })
        const a = (await ans.innerText()).trim()
        const label = await page.getByText('Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc').count()
        const errors = await page.locator('.msg-ai .body.error').count()
        return {
          ok: a === 'Câu trả lời sau khi hỏi lại.' && label > 0 && calls.length === 2,
          actual: `Câu trả lời: "${a}"; nhãn AI: ${label}; số request: ${calls.length}; khối lỗi còn lại: ${errors}; câu hỏi gửi lại: "${calls[1]?.question}"`,
        }
      },
    },
    {
      action: '(Ghi nhận) Giả lập 504 HTML như Nginx timeout',
      expect: 'Ghi lại thông điệp và việc có nút Hỏi lại (không tính đạt / không đạt) — RISK-008',
      run: async ({ page, notes }) => {
        await page.locator('textarea#question').fill('Câu hỏi thử 504')
        await page.locator('textarea#question').press('Enter')
        const body = page.locator('.msg-ai .body.error').last()
        await body.waitFor({ timeout: 10000 })
        const text = (await body.innerText()).replace(/\s+/g, ' ').trim()
        const retry = await body.getByRole('button', { name: 'Hỏi lại' }).count()
        notes.push(`Bước 4 (ghi nhận RISK-008): với 504 HTML, giao diện hiện "${text}", nút Hỏi lại: ${retry ? 'có' : 'không'}.`)
        return { ok: true, actual: `"${text}"; nút Hỏi lại: ${retry ? 'có' : 'không'}` }
      },
    },
  ],
})
