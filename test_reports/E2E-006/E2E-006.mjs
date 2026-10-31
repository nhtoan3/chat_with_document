// E2E-006 — Kiểm tra ô nhập câu hỏi
// Chạy từ gốc repo: node test_reports/E2E-006/E2E-006.mjs
import { runTest, mockAsk, WEB_URL } from '../../frontend/e2e/runner.mjs'

let calls = []
const box = (page) => page.locator('textarea#question')
const send = (page) => page.getByRole('button', { name: 'Gửi câu hỏi' })
const counter = (page) => page.locator('#question-meta span').last()

await runTest({
  id: 'E2E-006',
  title: 'Kiểm tra ô nhập câu hỏi',
  setup: 'check_stack && reset_data && seed_samples && wait_idle 300',
  cleanup: 'reset_data',
  notes: ['`/api/v1/ask` được giả lập (page.route) để đếm request, không gọi Claude.'],
  steps: [
    {
      action: 'Mở /ask, nhập 5 dấu cách, nhấn Enter',
      expect: 'Nút "Gửi câu hỏi" bị vô hiệu; Enter không tạo request',
      run: async ({ page }) => {
        calls = await mockAsk(page, [{ body: { answer: 'OK', latency_ms: 500 } }])
        await page.goto(`${WEB_URL}/ask`)
        await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        await box(page).fill('     ')
        await box(page).press('Enter')
        await page.waitForTimeout(800)
        const disabled = await send(page).isDisabled()
        return { ok: disabled && calls.length === 0, actual: `Nút Gửi disabled=${disabled}; số request: ${calls.length}` }
      },
    },
    {
      action: 'Dán 2001 ký tự',
      expect: 'Bộ đếm "2001/2000"; thông báo "Câu hỏi dài quá 1 ký tự."; nút Gửi bị vô hiệu',
      run: async ({ page, notes }) => {
        await box(page).fill('a'.repeat(2001))
        const c = counter(page)
        const text = (await c.innerText()).trim()
        const title = await c.getAttribute('title')
        const cls = await c.getAttribute('class')
        const visibleMsg = await page.getByText('Câu hỏi dài quá 1 ký tự.').count()
        const invalid = await box(page).getAttribute('aria-invalid')
        const disabled = await send(page).isDisabled()
        if (!visibleMsg)
          notes.push('Bước 2: thông báo "Câu hỏi dài quá 1 ký tự." chỉ nằm trong thuộc tính `title` (tooltip) của bộ đếm, không hiển thị trên màn hình. T-021 không bắt buộc hiển thị thông báo này nên bước vẫn tính Đạt; đề xuất (Minor/UX) hiển thị thông báo trực tiếp.')
        return {
          ok: text === '2001/2000' && title === 'Câu hỏi dài quá 1 ký tự.' && disabled,
          actual: `Bộ đếm "${text}" (class "${cls}", title "${title}"); thông báo hiển thị trên màn hình: ${visibleMsg ? 'có' : 'không (chỉ tooltip)'}; aria-invalid=${invalid}; nút Gửi disabled=${disabled}`,
        }
      },
    },
    {
      action: 'Xóa 1 ký tự (còn 2000)',
      expect: 'Bộ đếm "2000/2000"; nút Gửi dùng được',
      run: async ({ page }) => {
        await box(page).press('End')
        await box(page).press('Backspace')
        const text = (await counter(page).innerText()).trim()
        const enabled = await send(page).isEnabled()
        return { ok: text === '2000/2000' && enabled, actual: `Bộ đếm "${text}"; nút Gửi enabled=${enabled}` }
      },
    },
    {
      action: 'Xóa hết, gõ "dòng 1", Shift+Enter, gõ "dòng 2"',
      expect: 'Ô nhập có 2 dòng; không có request /api/v1/ask',
      run: async ({ page }) => {
        await box(page).fill('')
        await box(page).pressSequentially('dòng 1')
        await box(page).press('Shift+Enter')
        await box(page).pressSequentially('dòng 2')
        await page.waitForTimeout(500)
        const v = await box(page).inputValue()
        return { ok: v === 'dòng 1\ndòng 2' && calls.length === 0, actual: `Giá trị: ${JSON.stringify(v)}; số request: ${calls.length}` }
      },
    },
    {
      action: 'Nhấn Enter',
      expect: 'Đúng 1 request /api/v1/ask với question chứa xuống dòng',
      run: async ({ page }) => {
        await box(page).press('Enter')
        await page.locator('.msg-ai .answer').last().waitFor({ timeout: 10000 })
        const q = calls[0]?.question
        return { ok: calls.length === 1 && q === 'dòng 1\ndòng 2', actual: `Số request: ${calls.length}; question gửi đi: ${JSON.stringify(q)}` }
      },
    },
  ],
})
