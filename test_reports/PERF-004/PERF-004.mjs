// PERF-004 — bước UI 2–3 (API thật, Anthropic trỏ tới địa chỉ không phản hồi). Chạy từ gốc repo: node test_reports/PERF-004/PERF-004.mjs
import fs from 'node:fs'
import path from 'node:path'
import { startEvidence, WEB_URL } from '../../frontend/e2e/evidence.mjs'
const ev = await startEvidence('PERF-004')
const { page } = ev
const checks = []
const MAX = 200000
try {
  await page.goto(`${WEB_URL}/ask`)
  await page.getByRole('heading', { name: 'Bạn muốn tìm hiểu điều gì?' }).waitFor()
  await page.locator('nav .count', { hasText: /^3$/ }).waitFor({ timeout: 10000 })
  await ev.caption('Bước 2: gửi câu hỏi và bấm giờ')
  await page.locator('textarea#question').fill('Mức phạt khi chậm thanh toán là bao nhiêu?')
  await page.locator('textarea#question').press('Enter')
  const t0 = Date.now()
  await page.locator('.thinking').waitFor({ timeout: 3000 })
  const spin = (await page.locator('.thinking').innerText()).split('\n')[0]
  // giao diện vẫn thao tác được: gõ vào ô nhập, cuộn trang
  const ta = page.locator('textarea#question')
  const editable = await ta.isEditable()
  if (editable) await ta.fill('thử gõ khi đang chờ')
  const typed = editable ? await ta.inputValue() : ''
  await page.mouse.wheel(0, 200)
  await ev.shot('buoc-2-dang-cho')
  checks.push({ step: 2, ok: spin.includes('Đang tìm câu trả lời') && typed === 'thử gõ khi đang chờ', actual: `Spinner "${spin}"; ô nhập ${editable ? `gõ được ("${typed}")` : 'bị khóa khi đang chờ'}; cuộn thực hiện không lỗi` })
  await ev.caption('Bước 3: chờ thông báo lỗi (tối đa 200 s)')
  const err = page.locator('.msg-ai .body.error').last()
  const wait30 = 30000 - (Date.now() - t0)
  const appeared30 = await err.waitFor({ timeout: wait30 }).then(() => true).catch(() => false)
  await ev.shot('buoc-3-moc-30s')
  if (!appeared30) await err.waitFor({ timeout: MAX - (Date.now() - t0) }).catch(() => {})
  const seen = await err.count()
  const secs = ((Date.now() - t0) / 1000).toFixed(1)
  if (seen) {
    const text = (await err.innerText()).replace(/\s+/g, ' ').trim()
    const retry = await err.getByRole('button', { name: 'Hỏi lại' }).count()
    await ev.shot('buoc-3-thong-bao-loi')
    const msgOk = text.includes('Hệ thống đang bận, vui lòng thử lại.') && retry === 1
    checks.push({ step: 3, ok: msgOk && Number(secs) <= 30, seconds: Number(secs), actual: `Thông báo xuất hiện sau ${secs} s (mục tiêu ≤ 30 s). Nội dung: "${text}"; nút Hỏi lại: ${retry}` })
  } else {
    await ev.shot('buoc-3-het-200s')
    checks.push({ step: 3, ok: false, seconds: null, actual: `Không có thông báo lỗi sau ${secs} s` })
  }
} catch (e) { checks.push({ step: 'loi', ok: false, actual: String(e) }); await ev.shot('loi').catch(() => {}) }
finally {
  const { dir } = await ev.finish()
  fs.writeFileSync(path.join(dir, 'logs', 'checks-ui.json'), JSON.stringify(checks, null, 2)); console.table(checks)
}
