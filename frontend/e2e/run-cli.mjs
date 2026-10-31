#!/usr/bin/env node
// Run a shell script for a test case that has no UI (pytest, vitest, curl, psql…)
// and record evidence: output streams live into a terminal-style page that is
// video-recorded, and a screenshot is taken at the end of every step.
//
//   node frontend/e2e/run-cli.mjs <TEST_ID> <script.sh> [--cwd <dir>]
//
// The script is run with bash from <dir> (default: repository root).
// Mark steps with lines starting with "### " (e.g. `echo "### Bước 2: gọi API"`):
// the runner screenshots the previous step before the next one starts, and once more at the end.
// Outputs in ./test_reports/<TEST_ID>/: video.webm, screenshots/NN-*.png, logs/<script>.log
// Exit code = exit code of the script.
import { spawn } from 'node:child_process'
import fs from 'node:fs'
import path from 'node:path'
import { chromium } from 'playwright'
import { REPO_ROOT, testDir, nextShotPath, nextVideoPath } from './evidence.mjs'

const args = process.argv.slice(2)
const [testId, script] = args
if (!testId || !script) {
  console.error('usage: node frontend/e2e/run-cli.mjs <TEST_ID> <script.sh> [--cwd <dir>]')
  process.exit(2)
}
const cwdIdx = args.indexOf('--cwd')
const cwd = path.resolve(REPO_ROOT, cwdIdx > 0 ? args[cwdIdx + 1] : '.')
const scriptPath = path.resolve(process.cwd(), script)

const dir = testDir(testId)
const tmp = path.join(dir, '.video-tmp')
const logFile = path.join(dir, 'logs', `${path.basename(scriptPath).replace(/\.sh$/, '')}.log`)
const viewport = { width: 1280, height: 800 }

const browser = await chromium.launch()
const context = await browser.newContext({ viewport, recordVideo: { dir: tmp, size: viewport } })
const page = await context.newPage()
const esc = (s) => s.replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' })[c])
await page.setContent(`<!doctype html><meta charset="utf-8"><style>
  body{margin:0;background:#0d1117;color:#c9d1d9;font:13px/1.45 ui-monospace,Menlo,Consolas,monospace}
  header{position:sticky;top:0;background:#161b22;border-bottom:1px solid #30363d;padding:10px 16px;color:#e6edf3}
  header b{color:#58a6ff} pre{margin:0;padding:12px 16px;white-space:pre-wrap;word-break:break-word}
  .step{color:#d2a8ff;font-weight:bold} .err{color:#ff7b72} .end{color:#3fb950;font-weight:bold} .fail{color:#ff7b72;font-weight:bold}
</style><header><b>${esc(testId)}</b> · ${esc(path.relative(REPO_ROOT, scriptPath))} · cwd: ${esc(path.relative(REPO_ROOT, cwd) || '.')} · ${new Date().toISOString()}</header><pre id="out"></pre>`)

let queue = Promise.resolve()
const enqueue = (fn) => (queue = queue.then(fn).catch(() => {}))
const append = (text, cls = '') =>
  enqueue(() =>
    page.evaluate(
      ([t, c]) => {
        const span = document.createElement('span')
        if (c) span.className = c
        span.textContent = t
        document.getElementById('out').appendChild(span)
        window.scrollTo(0, document.body.scrollHeight)
      },
      [text, cls],
    ),
  )
let currentStep = 'bat-dau'
let stepHasOutput = false
const shot = (name) => enqueue(() => page.screenshot({ path: nextShotPath(dir, name), fullPage: true }))

const log = fs.createWriteStream(logFile)
const child = spawn('bash', [scriptPath], { cwd, env: { ...process.env, TEST_ID: testId, TEST_DIR: dir } })
const handle = (stream, cls) => {
  let buf = ''
  stream.on('data', (d) => {
    process[cls ? 'stderr' : 'stdout'].write(d)
    log.write(d)
    buf += d.toString()
    const lines = buf.split('\n')
    buf = lines.pop()
    for (const line of lines) {
      if (line.startsWith('### ')) {
        if (stepHasOutput) shot(currentStep)
        currentStep = line.slice(4)
        stepHasOutput = false
        append(line + '\n', 'step')
      } else {
        stepHasOutput = true
        append(line + '\n', cls)
      }
    }
  })
  stream.on('end', () => buf && append(buf + '\n', cls))
}
handle(child.stdout, '')
handle(child.stderr, 'err')
const code = await new Promise((r) => child.on('close', r))
log.end(`\n[exit code ${code}]\n`)
append(`\n[exit code ${code}]\n`, code === 0 ? 'end' : 'fail')
shot(`${currentStep}-ket-thuc`)
await queue
await page.waitForTimeout(1500)
const video = page.video()
await context.close()
await browser.close()
const videoFile = nextVideoPath(dir)
fs.renameSync(await video.path(), videoFile)
fs.rmSync(tmp, { recursive: true, force: true })
console.error(`\n[evidence] ${path.relative(REPO_ROOT, dir)}: ${path.basename(videoFile)}, screenshots/, logs/${path.basename(logFile)}`)
process.exit(code ?? 1)
