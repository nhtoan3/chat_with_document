// E2E-003 — Kiểm tra tệp phía client (> 10 tệp, > 20 MB)
// Chạy từ gốc repo: node test_reports/E2E-003/E2E-003.mjs
import fs from 'node:fs'
import path from 'node:path'
import { runTest, WEB_URL, FIXTURES } from '../../frontend/e2e/runner.mjs'

const posts = []

await runTest({
  id: 'E2E-003',
  title: 'Kiểm tra tệp phía client (> 10 tệp, > 20 MB)',
  setup:
    'check_stack && reset_data && for i in $(seq -w 1 11); do cp "$FIXTURES/sample/Hop_dong_khung_ABC_2026.pdf" "$DATA_DIR/tep_$i.pdf"; done && make_pdf big21mb "$DATA_DIR/qua_lon.pdf"',
  cleanup: 'reset_data',
  steps: [
    {
      action: 'Mở /documents, theo dõi request POST /api/v1/documents',
      expect: 'Trang trống',
      run: async ({ page }) => {
        page.on('request', (r) => {
          if (r.method() === 'POST' && r.url().includes('/api/v1/documents')) posts.push(r.postDataBuffer()?.length ?? 0)
        })
        await page.goto(`${WEB_URL}/documents`)
        await page.getByText('Chưa có tài liệu nào').waitFor()
        return { ok: true, actual: 'Trang trống "Chưa có tài liệu nào"' }
      },
    },
    {
      action: 'Chọn 11 tệp',
      expect: 'Banner "Mỗi lần chỉ tải tối đa 10 tệp. Bạn đã chọn 11 tệp — vui lòng chọn lại."; không có request POST',
      run: async ({ page, dir }) => {
        const files = fs.readdirSync(path.join(dir, 'data')).filter((f) => f.startsWith('tep_')).sort().map((f) => path.join(dir, 'data', f))
        await page.locator('#file-input').setInputFiles(files)
        const banner = page.getByRole('alert').filter({ hasText: 'Mỗi lần chỉ tải tối đa 10 tệp' })
        await banner.waitFor({ timeout: 5000 })
        await page.waitForTimeout(1500)
        const text = (await banner.innerText()).trim()
        return {
          ok: text.includes('Bạn đã chọn 11 tệp — vui lòng chọn lại.') && posts.length === 0,
          actual: `${files.length} tệp được chọn; banner: "${text.replace(/\s+/g, ' ')}"; số request POST: ${posts.length}`,
        }
      },
    },
    {
      action: 'Chọn qua_lon.pdf (21 MB) và 1 PDF mẫu',
      expect: 'qua_lon.pdf – "Vượt quá 20 MB"; đúng 1 request POST chỉ chứa tệp hợp lệ; "Đã tải lên 1 tệp, đang chờ xử lý."',
      run: async ({ page, dir }) => {
        await page.locator('#file-input').setInputFiles([path.join(dir, 'data', 'qua_lon.pdf'), path.join(FIXTURES, 'sample', 'Hop_dong_khung_ABC_2026.pdf')])
        const reject = page.locator('.reject', { hasText: 'qua_lon.pdf' })
        await reject.waitFor({ timeout: 10000 })
        const msg = (await reject.locator('.err-detail').innerText()).trim()
        await page.getByText('Đã tải lên 1 tệp, đang chờ xử lý.').waitFor({ timeout: 10000 })
        const sizeMb = posts.length ? (posts[0] / 1024 / 1024).toFixed(2) : '—'
        return {
          ok: msg === 'Vượt quá 20 MB' && posts.length === 1 && posts[0] < 1024 * 1024,
          actual: `qua_lon.pdf: "${msg}"; số request POST: ${posts.length}; kích thước body: ${sizeMb} MB (chỉ tệp hợp lệ); toast "Đã tải lên 1 tệp, đang chờ xử lý." hiện`,
        }
      },
    },
  ],
})
