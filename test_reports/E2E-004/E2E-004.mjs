// E2E-004 — Chưa có tài liệu Sẵn sàng: khóa ô hỏi
// Chạy từ gốc repo: node test_reports/E2E-004/E2E-004.mjs
import { runTest, WEB_URL } from '../../frontend/e2e/runner.mjs'

await runTest({
  id: 'E2E-004',
  title: 'Chưa có tài liệu Sẵn sàng: khóa ô hỏi',
  setup: 'check_stack && reset_data',
  steps: [
    {
      action: 'Mở http://localhost:5173/',
      expect: 'Tự chuyển tới /ask',
      run: async ({ page }) => {
        await page.goto(`${WEB_URL}/`)
        await page.waitForURL('**/ask')
        return { ok: new URL(page.url()).pathname === '/ask', actual: `URL: ${page.url()}` }
      },
    },
    {
      action: 'Quan sát vùng hỏi đáp',
      expect: '"Tải lên tài liệu để bắt đầu" + "Chưa có tài liệu nào ở trạng thái Sẵn sàng…"; ô nhập và nút "Gửi câu hỏi" bị vô hiệu',
      run: async ({ page }) => {
        await page.getByText('Chưa có tài liệu nào ở trạng thái Sẵn sàng', { exact: false }).waitFor()
        const title = await page.getByRole('heading', { name: 'Tải lên tài liệu để bắt đầu' }).count()
        const box = page.locator('textarea#question')
        const boxDisabled = await box.isDisabled()
        const placeholder = await box.getAttribute('placeholder')
        const sendDisabled = await page.getByRole('button', { name: 'Gửi câu hỏi' }).isDisabled()
        return {
          ok: title > 0 && boxDisabled && sendDisabled && placeholder === 'Tải lên tài liệu để bắt đầu',
          actual: `Tiêu đề khóa: ${title > 0 ? 'có' : 'không'}; textarea disabled=${boxDisabled}, placeholder="${placeholder}"; nút Gửi disabled=${sendDisabled}`,
        }
      },
    },
    {
      action: 'Bấm "Tải lên tài liệu"',
      expect: 'Chuyển tới /documents',
      run: async ({ page }) => {
        await page.getByRole('link', { name: 'Tải lên tài liệu' }).click()
        await page.waitForURL('**/documents')
        await page.getByRole('heading', { name: 'Tài liệu dự án' }).waitFor()
        return { ok: new URL(page.url()).pathname === '/documents', actual: `URL: ${page.url()}` }
      },
    },
  ],
})
