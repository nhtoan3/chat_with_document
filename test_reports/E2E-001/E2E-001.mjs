// E2E-001 — Tải lên PDF và theo dõi trạng thái tới Sẵn sàng
// Chạy từ gốc repo: node test_reports/E2E-001/E2E-001.mjs   (HEADED=1 để xem trình duyệt)
import path from 'node:path'
import { runTest, WEB_URL, FIXTURES } from '../../frontend/e2e/runner.mjs'

const SAMPLES = ['Bien_ban_hop_doi_tac_15-09.pdf', 'De_xuat_hop_tac_Minh_Phat.pdf', 'Hop_dong_khung_ABC_2026.pdf']
let navigations = 0
const readyToasts = new Set()

await runTest({
  id: 'E2E-001',
  title: 'Tải lên PDF và theo dõi trạng thái tới Sẵn sàng',
  setup: 'check_stack && reset_data',
  cleanup: 'reset_data',
  steps: [
    {
      action: 'Mở /documents',
      expect: 'Tiêu đề "Tài liệu dự án"; "Chưa có tài liệu nào"; "0/50 tài liệu"',
      run: async ({ page }) => {
        page.on('load', () => navigations++)
        await page.goto(`${WEB_URL}/documents`)
        await page.getByRole('heading', { name: 'Tài liệu dự án' }).waitFor()
        await page.getByText('Chưa có tài liệu nào').waitFor()
        const usage = await page.getByText('0/50 tài liệu').count()
        return { ok: usage > 0, actual: `Có tiêu đề và trạng thái trống; "0/50 tài liệu" xuất hiện ${usage} lần` }
      },
    },
    {
      action: 'Chọn 3 PDF mẫu + fake.pdf',
      expect: 'fake.pdf bị từ chối "Không phải tệp PDF hợp lệ"; nút "Đang tải lên…" khi gửi',
      run: async ({ page }) => {
        const files = [...SAMPLES.map((f) => path.join(FIXTURES, 'sample', f)), path.join(FIXTURES, 'fake.pdf')]
        const uploading = page.getByText('Đang tải lên…').waitFor({ timeout: 3000 }).then(() => true, () => false)
        await page.locator('#file-input').setInputFiles(files)
        const sawUploading = await uploading
        const reject = page.locator('.reject', { hasText: 'fake.pdf' })
        await reject.waitFor({ timeout: 15000 })
        const msg = await reject.locator('.err-detail').innerText()
        return {
          ok: msg.includes('Không phải tệp PDF hợp lệ'),
          actual: `fake.pdf: "${msg}"; trạng thái "Đang tải lên…" ${sawUploading ? 'đã hiển thị' : 'không bắt kịp (request rất nhanh)'}`,
        }
      },
    },
    {
      action: 'Chờ phản hồi tải lên',
      expect: 'Thông báo "Đã tải lên 3 tệp, đang chờ xử lý."; bảng 3 dòng; ghi chú tự cập nhật',
      run: async ({ page }) => {
        await page.getByText('Đã tải lên 3 tệp, đang chờ xử lý.').waitFor({ timeout: 10000 })
        await page.locator('tbody tr').nth(2).waitFor()
        const rows = await page.locator('tbody tr').count()
        const badges = await page.locator('tbody tr td:last-child').allInnerTexts()
        const poll = await page.getByText('Tự cập nhật mỗi 3 giây', { exact: false }).count()
        return {
          ok: rows === 3,
          actual: `Toast "Đã tải lên 3 tệp…" hiện; ${rows} dòng; trạng thái: ${badges.map((b) => b.trim()).join(', ')}; ghi chú tự cập nhật: ${poll ? 'có' : 'không (đã xử lý xong)'}`,
        }
      },
    },
    {
      action: 'Không tải lại trang, chờ tới khi cả 3 Sẵn sàng (≤ 5 phút)',
      expect: 'Mỗi dòng chuyển "Sẵn sàng"; mỗi tài liệu có toast "<tên>" đã sẵn sàng để hỏi đáp.',
      run: async ({ page, shot }) => {
        const deadline = Date.now() + 300_000
        let shotToast = false
        while (Date.now() < deadline) {
          for (const t of await page.locator('.toast').allInnerTexts()) {
            if (t.includes('đã sẵn sàng để hỏi đáp')) {
              if (!readyToasts.has(t) && !shotToast) {
                await shot('toast-da-san-sang')
                shotToast = true
              }
              readyToasts.add(t.trim())
            }
          }
          const ready = await page.locator('tbody tr', { hasText: 'Sẵn sàng' }).count()
          if (ready === 3) break
          await page.waitForTimeout(400)
        }
        await page.waitForTimeout(1500)
        for (const t of await page.locator('.toast').allInnerTexts()) if (t.includes('đã sẵn sàng')) readyToasts.add(t.trim())
        const ready = await page.locator('tbody tr', { hasText: 'Sẵn sàng' }).count()
        const named = SAMPLES.filter((f) => [...readyToasts].some((t) => t.includes(`"${f}"`)))
        return {
          ok: ready === 3 && named.length === 3,
          actual: `${ready}/3 dòng Sẵn sàng; toast sẵn sàng cho ${named.length}/3 tệp (${named.join(', ')})`,
        }
      },
    },
    {
      action: 'Kiểm tra bảng và sidebar',
      expect: 'Cột Tên tệp/Số trang/Ngày tải lên/Trạng thái; ngày dd/mm/yyyy; sidebar 3 (title "3 tài liệu Sẵn sàng"); không tải lại trang',
      run: async ({ page }) => {
        const heads = (await page.locator('thead th').allInnerTexts()).map((s) => s.trim())
        const dates = await page.locator('tbody tr td:nth-child(3)').allInnerTexts()
        const okDates = dates.every((d) => /^\d{2}\/\d{2}\/\d{4}$/.test(d.trim()))
        const count = page.locator('nav .count')
        const n = (await count.innerText()).trim()
        const title = await count.getAttribute('title')
        const okHeads = ['Tên tệp', 'Số trang', 'Ngày tải lên', 'Trạng thái'].every((h) => heads.includes(h))
        return {
          ok: okHeads && okDates && n === '3' && title === '3 tài liệu Sẵn sàng' && navigations === 1,
          actual: `Cột: ${heads.join(' / ')}; ngày: ${dates.join(', ')}; sidebar "${n}" (title "${title}"); số lần tải trang (load): ${navigations}`,
        }
      },
    },
  ],
})
