// E2E-002 — Tệp lỗi sau xử lý hiển thị đúng lý do
// Chạy từ gốc repo: node test_reports/E2E-002/E2E-002.mjs
import path from 'node:path'
import { runTest, WEB_URL, FIXTURES } from '../../frontend/e2e/runner.mjs'

const EXPECT = {
  'encrypted.pdf': 'Tệp có mật khẩu',
  'scanned.pdf': 'PDF dạng ảnh chưa được hỗ trợ',
  'corrupted.pdf': 'Tệp bị hỏng',
}

await runTest({
  id: 'E2E-002',
  title: 'Tệp lỗi sau xử lý hiển thị đúng lý do',
  setup: 'check_stack && reset_data && upload "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf" && wait_idle 300',
  cleanup: 'reset_data',
  steps: [
    {
      action: 'Mở /documents',
      expect: '1 dòng "Sẵn sàng"',
      run: async ({ page }) => {
        await page.goto(`${WEB_URL}/documents`)
        await page.locator('tbody tr').first().waitFor()
        const rows = await page.locator('tbody tr').allInnerTexts()
        return { ok: rows.length === 1 && rows[0].includes('Sẵn sàng'), actual: `${rows.length} dòng: ${rows.map((r) => r.replace(/\s+/g, ' ')).join(' | ')}` }
      },
    },
    {
      action: 'Tải lên encrypted.pdf, scanned.pdf, corrupted.pdf',
      expect: '3 dòng mới ở trạng thái đang chờ / đang xử lý',
      run: async ({ page }) => {
        await page.locator('#file-input').setInputFiles(Object.keys(EXPECT).map((f) => path.join(FIXTURES, f)))
        await page.locator('tbody tr').nth(3).waitFor({ timeout: 15000 })
        const states = []
        for (const f of Object.keys(EXPECT)) states.push(`${f}: ${(await page.locator('tbody tr', { hasText: f }).locator('td:last-child').innerText()).trim()}`)
        return { ok: true, actual: `4 dòng; ${states.join('; ')}` }
      },
    },
    {
      action: 'Chờ tới khi không còn tài liệu đang xử lý',
      expect: 'encrypted → Lỗi + "Tệp có mật khẩu"; scanned → Lỗi + "PDF dạng ảnh chưa được hỗ trợ"; corrupted → Lỗi + "Tệp bị hỏng"',
      run: async ({ page }) => {
        const deadline = Date.now() + 180_000
        while (Date.now() < deadline && (await page.locator('tbody tr', { hasText: /Đang chờ xử lý|Đang xử lý/ }).count()) > 0) await page.waitForTimeout(500)
        const out = []
        let ok = true
        for (const [f, msg] of Object.entries(EXPECT)) {
          const row = page.locator('tbody tr', { hasText: f })
          const status = (await row.locator('td:last-child').innerText()).trim()
          const detail = (await row.locator('.err-detail').innerText().catch(() => '')).trim()
          ok &&= status === 'Lỗi' && detail === msg
          out.push(`${f}: ${status} – "${detail}"`)
        }
        return { ok, actual: out.join('; ') }
      },
    },
    {
      action: 'Kiểm tra tài liệu Sẵn sàng ban đầu',
      expect: 'Hop_dong_khung_ABC_2026.pdf vẫn "Sẵn sàng"; sidebar vẫn 1',
      run: async ({ page }) => {
        const status = (await page.locator('tbody tr', { hasText: 'Hop_dong_khung_ABC_2026.pdf' }).locator('td:last-child').innerText()).trim()
        const n = (await page.locator('nav .count').innerText()).trim()
        return { ok: status === 'Sẵn sàng' && n === '1', actual: `ABC: ${status}; sidebar "${n}"` }
      },
    },
  ],
})
