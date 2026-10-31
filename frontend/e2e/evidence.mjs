// Evidence helper for agent-driven test cases (docs/07-verification/test_cases/).
// Records a video of the browser session and numbered screenshots into
// ./test_reports/<TEST_ID>/ at the repository root.
//
//   import { startEvidence, WEB_URL } from '../../frontend/e2e/evidence.mjs'
//   const ev = await startEvidence('E2E-001')
//   await ev.page.goto(`${WEB_URL}/documents`)
//   await ev.caption('Bước 1: mở trang Tài liệu')
//   await ev.shot('trang-tai-lieu-trong')
//   await ev.finish()          // -> video.webm, logs/browser-console.log
import { chromium } from 'playwright'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const HERE = path.dirname(fileURLToPath(import.meta.url))
export const REPO_ROOT = path.resolve(HERE, '../..')
export const REPORTS_ROOT = path.join(REPO_ROOT, 'test_reports')
export const FIXTURES = path.join(REPO_ROOT, 'backend/tests/fixtures/pdfs')
export const WEB_URL = process.env.WEB_URL ?? 'http://localhost:5173'
export const API_URL = process.env.API_URL ?? 'http://localhost:8000'

const slug = (s) =>
  s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 60)

export function testDir(testId) {
  const dir = path.join(REPORTS_ROOT, testId)
  for (const sub of ['screenshots', 'logs']) fs.mkdirSync(path.join(dir, sub), { recursive: true })
  return dir
}

export function nextShotPath(dir, name) {
  const shots = path.join(dir, 'screenshots')
  const n = fs.readdirSync(shots).filter((f) => f.endsWith('.png')).length + 1
  return path.join(shots, `${String(n).padStart(2, '0')}-${slug(name) || 'shot'}.png`)
}

export function nextVideoPath(dir) {
  const first = path.join(dir, 'video.webm')
  if (!fs.existsSync(first)) return first
  let i = 2
  while (fs.existsSync(path.join(dir, `video-${String(i).padStart(2, '0')}.webm`))) i++
  return path.join(dir, `video-${String(i).padStart(2, '0')}.webm`)
}

/**
 * Start a recorded browser session for one test case.
 * @param {string} testId e.g. 'E2E-001'
 * @param {{headless?: boolean, viewport?: {width:number,height:number}}} [opts]
 */
export async function startEvidence(testId, opts = {}) {
  const viewport = opts.viewport ?? { width: 1440, height: 900 }
  const dir = testDir(testId)
  const tmp = path.join(dir, '.video-tmp')
  // HEADED=1 shows the browser window; default is headless (video is recorded either way).
  const browser = await chromium.launch({ headless: opts.headless ?? process.env.HEADED !== '1', slowMo: Number(process.env.SLOWMO ?? 0) })
  const context = await browser.newContext({
    viewport,
    locale: 'vi-VN',
    recordVideo: { dir: tmp, size: viewport },
  })
  const page = await context.newPage()
  const consoleLines = []
  page.on('console', (m) => consoleLines.push(`[${m.type()}] ${m.text()}`))
  page.on('pageerror', (e) => consoleLines.push(`[pageerror] ${e.message}`))
  page.on('dialog', (d) => {
    consoleLines.push(`[dialog:${d.type()}] ${d.message()}`)
    d.dismiss().catch(() => {})
  })

  /** Show the current step as a banner in the video (hidden in screenshots). */
  async function caption(text) {
    await page
      .evaluate((t) => {
        let el = document.getElementById('__evidence_caption')
        if (!el) {
          el = document.createElement('div')
          el.id = '__evidence_caption'
          el.style.cssText =
            'position:fixed;left:12px;bottom:12px;z-index:2147483647;max-width:70vw;padding:6px 10px;' +
            'background:rgba(17,24,39,.85);color:#fff;font:13px/1.4 system-ui,sans-serif;border-radius:6px;pointer-events:none'
          document.body.appendChild(el)
        }
        el.textContent = t
      }, `${testId} · ${text}`)
      .catch(() => {})
  }

  /** Numbered screenshot; returns the path relative to the test folder. */
  async function shot(name, { fullPage = true } = {}) {
    const file = nextShotPath(dir, name)
    await page.evaluate(() => {
      const el = document.getElementById('__evidence_caption')
      if (el) el.style.visibility = 'hidden'
    }).catch(() => {})
    await page.screenshot({ path: file, fullPage })
    await page.evaluate(() => {
      const el = document.getElementById('__evidence_caption')
      if (el) el.style.visibility = 'visible'
    }).catch(() => {})
    return path.relative(dir, file)
  }

  /** Close the browser, move the video to video.webm and write the console log. */
  async function finish() {
    const video = page.video()
    await page.waitForTimeout(1000)
    await context.close()
    await browser.close()
    let videoFile = null
    if (video) {
      videoFile = nextVideoPath(dir)
      fs.renameSync(await video.path(), videoFile)
    }
    fs.rmSync(tmp, { recursive: true, force: true })
    fs.appendFileSync(path.join(dir, 'logs', 'browser-console.log'), consoleLines.join('\n') + '\n')
    return { dir, video: videoFile && path.relative(dir, videoFile) }
  }

  return { dir, browser, context, page, caption, shot, finish }
}
