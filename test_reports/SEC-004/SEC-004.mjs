// SEC-004 — bước UI 2–3. Chạy từ gốc repo: node test_reports/SEC-004/SEC-004.mjs
import { execSync } from 'node:child_process'
import fs from 'node:fs'
import path from 'node:path'
import { startEvidence, WEB_URL, REPO_ROOT } from '../../frontend/e2e/evidence.mjs'
execSync(`bash -c 'source frontend/e2e/lib.sh && check_stack && reset_data && seed_samples && wait_idle 300'`, { cwd: REPO_ROOT, stdio: 'ignore', env: { ...process.env, TEST_DIR: path.join(REPO_ROOT, 'test_reports/SEC-004') } })
const PAYLOAD = `<img src=x onerror="alert(1)">\n\n<svg onload=alert(2)>\n\n<iframe src="javascript:alert(3)"></iframe>\n\n<a href="javascript:alert(4)">x</a>\n\n<script>alert(5)</script>`
const ev = await startEvidence('SEC-004')
const { page } = ev
const checks = []; const dialogs = []
page.on('dialog', (d) => dialogs.push(d.message()))
try {
  await page.route('**/api/v1/ask', (r) => r.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ answer: PAYLOAD, latency_ms: 900 }) }))
  await page.goto(`${WEB_URL}/ask`)
  await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
  await page.locator('nav .count', { hasText: /^3$/ }).waitFor({ timeout: 10000 }).catch(() => {})
  await ev.caption('Bước 2: gửi câu hỏi, API giả lập trả payload XSS')
  await page.locator('textarea#question').fill('Cho tôi xem câu trả lời')
  await page.locator('textarea#question').press('Enter')
  const ans = page.locator('.msg-ai .answer').last()
  await ans.waitFor({ timeout: 10000 }); await page.waitForTimeout(2000)
  checks.push({ step: 2, ok: true, actual: `Câu trả lời hiển thị, innerText: ${JSON.stringify((await ans.innerText()).trim())}` })
  await ev.shot('buoc-2-cau-tra-loi')
  await ev.caption('Bước 3: kiểm tra dialog và DOM')
  const html = await ans.evaluate((e) => e.outerHTML)
  fs.writeFileSync(path.join(ev.dir ?? path.join(REPO_ROOT, 'test_reports/SEC-004'), 'logs', 'answer-dom.html'), html + '\n')
  const i = await ans.evaluate((el) => ({
    script: el.querySelectorAll('script').length, iframe: el.querySelectorAll('iframe').length,
    on: [...el.querySelectorAll('*')].flatMap((n) => [...n.attributes].filter((a) => a.name.toLowerCase().startsWith('on')).map((a) => `${n.tagName}.${a.name}`)),
    js: [...el.querySelectorAll('*')].flatMap((n) => [...n.attributes].filter((a) => /^\s*javascript:/i.test(a.value)).map((a) => `${n.tagName}.${a.name}`)),
  }))
  checks.push({ step: 3, ok: dialogs.length === 0 && !i.script && !i.iframe && !i.on.length && !i.js.length, actual: `dialog: ${dialogs.length}; script: ${i.script}; iframe: ${i.iframe}; on*: ${i.on.length}; javascript: ${i.js.length}. outerHTML ở logs/answer-dom.html` })
  await ev.shot('buoc-3-dom')
} catch (e) { checks.push({ step: 'loi', ok: false, actual: String(e) }); await ev.shot('loi').catch(() => {}) }
finally {
  const { dir } = await ev.finish()
  fs.writeFileSync(path.join(dir, 'logs', 'checks-ui.json'), JSON.stringify(checks, null, 2)); console.table(checks)
}
