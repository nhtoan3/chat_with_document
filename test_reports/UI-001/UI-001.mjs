// UI-001 — Giao diện khớp thiết kế HTML (bản tối giản)
// Chạy từ gốc repo: node test_reports/UI-001/UI-001.mjs
import fs from 'node:fs'
import path from 'node:path'
import { runTest, mockAsk, WEB_URL, REPO_ROOT, FIXTURES } from '../../frontend/e2e/runner.mjs'

const design = (f) => 'file://' + encodeURI(path.join(REPO_ROOT, 'docs/04-design/html_design', f))
const SELS = ['body', 'h1', '.sub', '.btn-primary', '.badge.b-ready', '.badge.b-fail', '.badge.b-proc', '.badge.b-queue', 'th', 'td', '.card', '.meter', '.sidebar', 'aside', 'nav', 'header', '.topbar', 'textarea', '.composer', '.msg-user .body', '.msg-ai .body', '.answer']
const PROPS = ['fontFamily', 'fontSize', 'fontWeight', 'color', 'backgroundColor', 'borderRadius']
const probe = (page) => page.evaluate(([sels, props]) => Object.fromEntries(sels.map((s) => {
  const e = document.querySelector(s); if (!e) return [s, null]
  const cs = getComputedStyle(e); const r = e.getBoundingClientRect()
  return [s, { ...Object.fromEntries(props.map((p) => [p, cs[p]])), w: Math.round(r.width), h: Math.round(r.height), x: Math.round(r.x), y: Math.round(r.y) }]
})), [SELS, PROPS])
const out = {}
let ask = null, docsCheck = null

await runTest({
  id: 'UI-001',
  title: 'Giao diện khớp thiết kế HTML (bản tối giản)',
  setup: `check_stack && reset_data && seed_samples && upload "$FIXTURES/corrupted.pdf" && wait_idle 300`,
  cleanup: 'reset_data',
  notes: ['`/api/v1/ask` được giả lập ở bước 2 (test case cho phép "có thể giả lập API"): trả câu trả lời mẫu không có trích dẫn.'],
  steps: [
    {
      action: 'Chụp 03-documents.html và /documents cùng kích thước 1440×900',
      expect: '2 ảnh để so sánh',
      run: async ({ page, shot }) => {
        await page.goto(design('03-documents.html'), { waitUntil: 'load' }); await page.waitForTimeout(800)
        await shot('thiet-ke-03-documents', { fullPage: false }); out.design03 = await probe(page)
        await page.goto(`${WEB_URL}/documents`); await page.locator('.badge.b-ready').first().waitFor({ timeout: 15000 }); await page.waitForTimeout(500)
        await shot('app-documents', { fullPage: false }); out.appDocs = await probe(page)
        docsCheck = await page.evaluate(() => ({
          dragText: /Kéo-thả|Kéo thả/i.test(document.body.innerText),
          rowProgress: [...document.querySelectorAll('[role=progressbar], progress')].filter((e) => !e.closest('.usage')).length,
          tabs: document.querySelectorAll('[role=tab], .tabs').length,
          search: document.querySelectorAll('input[type=search], .search').length,
          removeBtn: document.querySelectorAll('[data-remove], [aria-label^="Gỡ"]').length + (/\bGỡ\b/.test(document.body.innerText) ? 1 : 0),
          h1: document.querySelector('h1')?.innerText, cols: [...document.querySelectorAll('th')].map((e) => e.innerText),
        }))
        return { ok: true, actual: 'Đã chụp 2 ảnh 1440×900' }
      },
    },
    {
      action: 'Chụp 04-chat.html và /ask (sau khi hỏi 1 câu, API giả lập)',
      expect: '2 ảnh để so sánh',
      run: async ({ page, shot }) => {
        await page.goto(design('04-chat.html'), { waitUntil: 'load' }); await page.waitForTimeout(800)
        await shot('thiet-ke-04-chat', { fullPage: false }); out.design04 = await probe(page)
        await mockAsk(page, [{ body: { answer: 'Theo hợp đồng khung với ABC:\n\n- Tạm ứng **30%** giá trị đơn hàng\n- Trong vòng **10 ngày làm việc** kể từ ngày ký.', latency_ms: 1200 } }])
        await page.goto(`${WEB_URL}/ask`); await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
        await page.locator('nav .count', { hasText: /^3$/ }).waitFor({ timeout: 10000 }).catch(() => {})
        await page.locator('textarea#question').fill('Điều khoản tạm ứng trong hợp đồng khung với ABC là gì?')
        await page.locator('textarea#question').press('Enter')
        await page.locator('.msg-ai .answer').last().waitFor({ timeout: 10000 }); await page.waitForTimeout(500)
        await shot('app-ask', { fullPage: false }); out.appAsk = await probe(page)
        ask = await page.evaluate(() => ({
          cite: document.querySelectorAll('.cite').length, sources: document.querySelectorAll('.sources').length + (/Nguồn \(/.test(document.body.innerText) ? 1 : 0),
          panel: document.querySelectorAll('aside.panel, .panel').length,
          feedback: document.querySelectorAll('[data-feedback], [aria-label*="hữu ích"], [aria-label*="Đánh giá"]').length + (/Đánh giá/.test(document.body.innerText) ? 1 : 0),
          stop: /\bDừng\b/.test(document.body.innerText), recent: /Gần đây/.test(document.body.innerText),
        }))
        return { ok: true, actual: 'Đã chụp 2 ảnh 1440×900' }
      },
    },
    {
      action: 'So sánh và lập bảng khác biệt trong báo cáo',
      expect: 'Bố cục, màu, nhãn tương đương; không có thành phần đã bỏ (Tài liệu: kéo-thả, thanh tiến trình, tab, tìm kiếm, nút gỡ; Hỏi đáp: trích dẫn, Nguồn, panel PDF, đánh giá, nút Dừng, Gần đây)',
      run: async ({ dir }) => {
        fs.writeFileSync(path.join(dir, 'logs', 'style-compare.json'), JSON.stringify(out, null, 2))
        fs.writeFileSync(path.join(dir, 'logs', 'removed-components.json'), JSON.stringify({ documents: docsCheck, ask }, null, 2))
        const d = docsCheck, a = ask
        const clean = !d.dragText && d.rowProgress === 0 && d.tabs === 0 && d.search === 0 && d.removeBtn === 0 && a.cite === 0 && a.sources === 0 && a.panel === 0 && a.feedback === 0 && !a.stop && !a.recent
        return { ok: clean, actual: `Thành phần đã bỏ — Tài liệu: ${JSON.stringify(d)}; Hỏi đáp: ${JSON.stringify(a)}. (Chỉ phần này được assert tự động; so sánh bố cục xem ghi chú.)` }
      },
    },
  ],
})
