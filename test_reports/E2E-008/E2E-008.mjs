// E2E-008 — XSS trong câu trả lời không được thực thi
// Chạy từ gốc repo: node test_reports/E2E-008/E2E-008.mjs
import fs from 'node:fs'
import path from 'node:path'
import { runTest, mockAsk, WEB_URL } from '../../frontend/e2e/runner.mjs'

const PAYLOAD =
  "**In đậm**\n\n<img src=x onerror=\"alert('xss-img')\">\n<script>alert('xss-script')</script>\n\n[bấm vào](javascript:alert('xss-link'))"
const dialogs = []

await runTest({
  id: 'E2E-008',
  title: 'XSS trong câu trả lời không được thực thi',
  setup: 'check_stack && reset_data && seed_samples && wait_idle 300',
  cleanup: 'reset_data',
  notes: ['`/api/v1/ask` được giả lập trả `answer` = ' + '`' + PAYLOAD.replace(/\n/g, '\\n') + '`.'],
  steps: [
    {
      action: 'Mở /ask và gửi một câu hỏi bất kỳ',
      expect: 'Câu trả lời giả lập hiển thị; "In đậm" được in đậm',
      run: async ({ page }) => {
        page.on('dialog', (d) => dialogs.push(`${d.type()}: ${d.message()}`))
        await mockAsk(page, [{ body: { answer: PAYLOAD, latency_ms: 900 } }])
        await page.goto(`${WEB_URL}/ask`)
        await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        await page.locator('textarea#question').fill('Cho tôi xem câu trả lời')
        await page.locator('textarea#question').press('Enter')
        const ans = page.locator('.msg-ai .answer').last()
        await ans.waitFor({ timeout: 10000 })
        await page.waitForTimeout(1500)
        const strong = await ans.locator('strong').allInnerTexts()
        return { ok: strong.includes('In đậm'), actual: `Câu trả lời hiển thị; <strong>: ${strong.join(', ')}` }
      },
    },
    {
      action: 'Kiểm tra hộp thoại',
      expect: 'Không có dialog nào',
      run: async () => ({ ok: dialogs.length === 0, actual: `Số dialog: ${dialogs.length}${dialogs.length ? ` (${dialogs.join('; ')})` : ''}` }),
    },
    {
      action: 'Kiểm tra DOM vùng câu trả lời',
      expect: 'Không có <script>; không có thuộc tính on*; không có href javascript:',
      run: async ({ page, dir }) => {
        const ans = page.locator('.msg-ai .answer').last()
        const html = await ans.evaluate((el) => el.outerHTML)
        fs.writeFileSync(path.join(dir, 'logs', 'answer-dom.html'), html + '\n')
        const info = await ans.evaluate((el) => ({
          scripts: el.querySelectorAll('script').length,
          imgs: el.querySelectorAll('img').length,
          onAttrs: [...el.querySelectorAll('*')].flatMap((n) => [...n.attributes].filter((a) => a.name.startsWith('on')).map((a) => `${n.tagName}.${a.name}`)),
          jsLinks: [...el.querySelectorAll('[href]')].map((a) => a.getAttribute('href')).filter((h) => /^\s*javascript:/i.test(h ?? '')),
          links: el.querySelectorAll('a').length,
        }))
        return {
          ok: info.scripts === 0 && info.onAttrs.length === 0 && info.jsLinks.length === 0,
          actual: `script: ${info.scripts}; img: ${info.imgs}; thuộc tính on*: ${info.onAttrs.length ? info.onAttrs.join(', ') : 'không có'}; href javascript:: ${info.jsLinks.length}; số thẻ <a>: ${info.links}. outerHTML lưu ở logs/answer-dom.html`,
        }
      },
    },
    {
      action: 'Bấm vào liên kết "bấm vào" (nếu còn)',
      expect: 'Không có alert, không điều hướng sang javascript:',
      run: async ({ page }) => {
        const link = page.locator('.msg-ai .answer a', { hasText: 'bấm vào' })
        const before = page.url()
        if ((await link.count()) === 0) return { ok: dialogs.length === 0, actual: 'Liên kết đã bị loại bỏ (chỉ còn chữ); không có dialog' }
        await link.click({ timeout: 3000 }).catch(() => {})
        await page.waitForTimeout(1000)
        return { ok: dialogs.length === 0 && page.url() === before, actual: `Sau khi bấm: dialog ${dialogs.length}; URL ${page.url()}` }
      },
    },
  ],
})
