// UI-003 — Badge trạng thái có icon và chữ
// Chạy từ gốc repo: node test_reports/UI-003/UI-003.mjs
import fs from 'node:fs'
import path from 'node:path'
import { runTest, FIXTURES, WEB_URL } from '../../frontend/e2e/runner.mjs'
import { nextShotPath } from '../../frontend/e2e/evidence.mjs'

const captured = {}
async function grab(page, dir, tone, label) {
  const b = page.locator(`.badge.${tone}`).first()
  await b.waitFor({ timeout: 1000 })
  captured[label] = {
    html: await b.evaluate((e) => e.outerHTML),
    svg: await b.locator('svg').count(),
    text: (await b.innerText()).trim(),
  }
  await b.screenshot({ path: nextShotPath(dir, `can-canh-${tone}`) }).catch(() => {})
}

await runTest({
  id: 'UI-003',
  title: 'Badge trạng thái có icon và chữ',
  setup: 'check_stack && reset_data && "${COMPOSE[@]}" stop worker',
  cleanup: '"${COMPOSE[@]}" start worker && reset_data',
  notes: ['Theo ghi chú của test case: dừng `worker` trước khi tải lên để chụp "Đang chờ xử lý", rồi bật lại để bắt "Đang xử lý" (lấy mẫu DOM mỗi 100 ms).'],
  steps: [
    {
      action: 'Mở /documents, tải lên 3 PDF mẫu và corrupted.pdf; chụp ngay sau khi tải',
      expect: 'Thấy badge "Đang chờ xử lý" và/hoặc "Đang xử lý"',
      run: async ({ page, dir }) => {
        await page.goto(`${WEB_URL}/documents`)
        await page.locator('input[type=file]').setInputFiles(['sample/Hop_dong_khung_ABC_2026.pdf', 'sample/De_xuat_hop_tac_Minh_Phat.pdf', 'sample/Bien_ban_hop_doi_tac_15-09.pdf', 'corrupted.pdf'].map((f) => path.join(FIXTURES, f)))
        await page.locator('.badge.b-queue').first().waitFor({ timeout: 15000 })
        await grab(page, dir, 'b-queue', 'queued')
        const n = await page.locator('.badge.b-queue').count()
        return { ok: n === 4 && captured.queued.text === 'Đang chờ xử lý', actual: `${n} badge "${captured.queued.text}" (worker đang dừng)` }
      },
    },
    {
      action: 'Chờ hết xử lý, chụp bảng',
      expect: 'Badge "Sẵn sàng" và "Lỗi" (kèm "Tệp bị hỏng")',
      run: async ({ page, dir, sh }) => {
        sh('"${COMPOSE[@]}" start worker')
        const t0 = Date.now()
        while (Date.now() - t0 < 300000) {
          if (!captured.processing && (await page.locator('.badge.b-proc').count())) await grab(page, dir, 'b-proc', 'processing').catch(() => {})
          const left = await page.locator('.badge.b-queue, .badge.b-proc').count()
          if (left === 0 && (await page.locator('table .badge').count()) === 4) break
          await page.waitForTimeout(100)
        }
        await grab(page, dir, 'b-ready', 'ready')
        await grab(page, dir, 'b-fail', 'failed')
        const failRow = page.locator('tr', { has: page.locator('.badge.b-fail') })
        const detail = (await failRow.locator('.err-detail').innerText()).trim()
        const ready = await page.locator('.badge.b-ready').count()
        return { ok: ready === 3 && captured.failed.text === 'Lỗi' && detail === 'Tệp bị hỏng', actual: `${ready} "${captured.ready.text}"; 1 "${captured.failed.text}" kèm "${detail}"; bắt được "Đang xử lý": ${captured.processing ? 'có' : 'không'}` }
      },
    },
    {
      action: 'Kiểm tra DOM từng badge (chụp cận cảnh từng loại)',
      expect: 'Mỗi badge có phần tử icon (svg) và chữ; ghi outerHTML của mỗi loại vào logs/badges.html',
      run: async ({ dir }) => {
        const want = { queued: 'Đang chờ xử lý', processing: 'Đang xử lý', ready: 'Sẵn sàng', failed: 'Lỗi' }
        fs.writeFileSync(path.join(dir, 'logs', 'badges.html'), Object.entries(captured).map(([k, v]) => `<!-- ${k} -->\n${v.html}`).join('\n') + '\n')
        const rows = Object.entries(want).map(([k, w]) => ({ k, ok: captured[k]?.svg >= 1 && captured[k]?.text === w, s: captured[k] ? `${k}: svg=${captured[k].svg}, chữ="${captured[k].text}"` : `${k}: KHÔNG bắt được` }))
        return { ok: rows.every((r) => r.ok), actual: rows.map((r) => r.s).join('; ') }
      },
    },
  ],
})
