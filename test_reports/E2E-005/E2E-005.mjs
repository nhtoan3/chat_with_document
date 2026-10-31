// E2E-005 — Hỏi và nhận câu trả lời
// Chạy từ gốc repo: node test_reports/E2E-005/E2E-005.mjs
// Không có ANTHROPIC_API_KEY → giả lập /api/v1/ask (đúng như test case cho phép).
import { runTest, mockAsk, WEB_URL, API_URL } from '../../frontend/e2e/runner.mjs'

const Q = 'Điều khoản tạm ứng trong hợp đồng khung với ABC là gì?'
const MOCK = {
  delayMs: 3000,
  body: {
    answer: 'Theo hợp đồng khung với ABC:\n\n- Tạm ứng **30%** giá trị đơn hàng\n- Thời hạn: trong vòng **10 ngày làm việc** kể từ ngày ký hợp đồng.',
    latency_ms: 8421,
  },
}
let realStatus = '?'
let calls = []

await runTest({
  id: 'E2E-005',
  title: 'Hỏi và nhận câu trả lời',
  setup: 'check_stack && reset_data && seed_samples && wait_idle 300',
  cleanup: 'reset_data',
  notes: [],
  steps: [
    {
      action: 'Mở /ask',
      expect: 'Sidebar 3 tài liệu Sẵn sàng; "Bạn muốn tìm hiểu điều gì?"; ô nhập dùng được',
      run: async ({ page, notes }) => {
        // Ghi nhận API thật khi không có khóa (không tính đạt/không đạt)
        const r = await fetch(`${API_URL}/api/v1/ask`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ question: Q }) })
        realStatus = `${r.status} ${(await r.json()).code ?? ''}`.trim()
        notes.push(`Không có ANTHROPIC_API_KEY trên máy chạy test: gọi thật \`POST /api/v1/ask\` trả \`${realStatus}\`. Các bước 2–3 dùng **API giả lập** (page.route, trễ 3 s) theo điều kiện tiên quyết của test case; phần gọi Claude thật chưa được kiểm chứng (xem INT-022, EVAL-*).`)
        calls = await mockAsk(page, [MOCK])
        await page.goto(`${WEB_URL}/ask`)
        await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        // Chờ GET /documents trả về (số đếm ban đầu là 0 trong lúc tải)
        await page.locator('nav .count', { hasText: /^3$/ }).waitFor({ timeout: 10000 }).catch(() => {})
        const n = (await page.locator('nav .count').innerText()).trim()
        const enabled = await page.locator('textarea#question').isEnabled()
        return { ok: n === '3' && enabled, actual: `Sidebar "${n}"; lời chào hiển thị; textarea enabled=${enabled}` }
      },
    },
    {
      action: `Nhập "${Q}" và nhấn Enter`,
      expect: 'Bong bóng câu hỏi; "Đang tìm câu trả lời…" và "Có thể mất tới 20 giây"',
      run: async ({ page }) => {
        await page.locator('textarea#question').fill(Q)
        await page.locator('textarea#question').press('Enter')
        await page.locator('.thinking').waitFor({ timeout: 2000 })
        const user = (await page.locator('.msg-user').last().innerText()).trim()
        const thinking = (await page.locator('.thinking').innerText()).replace(/\s+/g, ' ').trim()
        return {
          ok: user === Q && thinking.includes('Đang tìm câu trả lời…') && thinking.includes('Có thể mất tới 20 giây'),
          actual: `Bong bóng: "${user}"; trạng thái chờ: "${thinking}"`,
        }
      },
    },
    {
      action: 'Chờ câu trả lời (tối đa 60 s)',
      expect: 'Câu trả lời Markdown nêu tạm ứng 30%; nhãn "Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc"; "Trả lời trong N giây"',
      run: async ({ page }) => {
        const ans = page.locator('.msg-ai .answer').last()
        await ans.waitFor({ timeout: 60000 })
        const strong = await ans.locator('strong').allInnerTexts()
        const lis = await ans.locator('li').count()
        const foot = (await page.locator('.ai-foot').last().innerText()).replace(/\s+/g, ' ').trim()
        return {
          ok: strong.includes('30%') && lis === 2 && foot.includes('Câu trả lời do AI tạo — hãy đối chiếu tài liệu gốc') && /Trả lời trong [\d,]+ giây/.test(foot),
          actual: `In đậm: ${strong.join(', ')}; ${lis} mục danh sách; chân: "${foot}"; số request /ask (giả lập): ${calls.length}`,
        }
      },
    },
  ],
})
