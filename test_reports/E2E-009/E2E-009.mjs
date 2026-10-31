// E2E-009 — Lịch sử hỏi đáp chỉ giữ trong trang
// Chạy từ gốc repo: node test_reports/E2E-009/E2E-009.mjs
import { runTest, mockAsk, WEB_URL } from '../../frontend/e2e/runner.mjs'

await runTest({
  id: 'E2E-009',
  title: 'Lịch sử hỏi đáp chỉ giữ trong trang',
  setup: 'check_stack && reset_data && seed_samples && wait_idle 300',
  cleanup: 'reset_data',
  notes: ['`/api/v1/ask` được giả lập trả lần lượt "Trả lời 1", "Trả lời 2".'],
  steps: [
    {
      action: 'Gửi "Câu hỏi 1" rồi "Câu hỏi 2"',
      expect: 'Hiển thị 2 cặp theo thứ tự Câu hỏi 1 → Trả lời 1 → Câu hỏi 2 → Trả lời 2',
      run: async ({ page }) => {
        await mockAsk(page, [{ body: { answer: 'Trả lời 1', latency_ms: 500 } }, { body: { answer: 'Trả lời 2', latency_ms: 600 } }])
        await page.goto(`${WEB_URL}/ask`)
        await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        for (const [i, q] of ['Câu hỏi 1', 'Câu hỏi 2'].entries()) {
          await page.locator('textarea#question').fill(q)
          await page.locator('textarea#question').press('Enter')
          await page.locator('.msg-ai .answer').nth(i).waitFor({ timeout: 10000 })
        }
        const seq = await page.locator('.msg-user, .msg-ai .answer').allInnerTexts()
        const order = seq.map((s) => s.trim())
        return {
          ok: JSON.stringify(order) === JSON.stringify(['Câu hỏi 1', 'Trả lời 1', 'Câu hỏi 2', 'Trả lời 2']),
          actual: `Thứ tự: ${order.join(' → ')}`,
        }
      },
    },
    {
      action: 'Tải lại trang',
      expect: 'Không còn cặp hỏi–đáp; hiện "Bạn muốn tìm hiểu điều gì?"',
      run: async ({ page }) => {
        await page.reload()
        await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        const left = await page.locator('.msg-user').count()
        return { ok: left === 0, actual: `Số bong bóng câu hỏi còn lại: ${left}; lời chào hiển thị` }
      },
    },
  ],
})
