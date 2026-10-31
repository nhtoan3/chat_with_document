// Step runner for UI test cases: wraps evidence.mjs, records each step's result,
// and writes ./test_reports/<ID>/report.md + logs/checks.json.
//
//   await runTest({ id, title, setup: 'reset_data', steps: [{ action, expect, run: async (ctx) => ({ ok, actual }) }] })
import { execSync } from 'node:child_process'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import { startEvidence, REPORTS_ROOT, REPO_ROOT, WEB_URL, API_URL, FIXTURES } from './evidence.mjs'

export { WEB_URL, API_URL, FIXTURES, REPO_ROOT }

const q = (s) => `'${s.replace(/'/g, `'\\''`)}'`

/** Run a lib.sh command (e.g. 'reset_data && seed_samples'); output appended to logs/setup.log. */
export function sh(dir, cmd) {
  const out = execSync(`bash -c ${q(`source frontend/e2e/lib.sh && ${cmd}`)}`, {
    cwd: REPO_ROOT,
    env: { ...process.env, TEST_DIR: dir },
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
    maxBuffer: 64 * 1024 * 1024,
  })
  fs.appendFileSync(path.join(dir, 'logs', 'setup.log'), `$ ${cmd}\n${out}\n`)
  return out
}

/** Fulfil /api/v1/ask with the given responses in order (last one repeats). Returns the request log. */
export async function mockAsk(page, responses) {
  const calls = []
  await page.route('**/api/v1/ask', async (route) => {
    const r = responses[Math.min(calls.length, responses.length - 1)]
    calls.push(JSON.parse(route.request().postData() || '{}'))
    if (r.delayMs) await new Promise((res) => setTimeout(res, r.delayMs))
    await route.fulfill({
      status: r.status ?? 200,
      contentType: r.contentType ?? 'application/json',
      body: typeof r.body === 'string' ? r.body : JSON.stringify(r.body),
    })
  })
  return calls
}

function env() {
  const git = (c) => {
    try {
      return execSync(c, { cwd: REPO_ROOT, encoding: 'utf8' }).trim()
    } catch {
      return '?'
    }
  }
  const dirty = git('git status --porcelain') ? ' (có thay đổi chưa commit)' : ''
  return {
    commit: `${git('git rev-parse --short HEAD')}${dirty}`,
    os: `${os.type()} ${os.release()} ${os.arch()}`,
    docker: git("docker version --format '{{.Server.Version}}'"),
    key: process.env.ANTHROPIC_API_KEY || fs.existsSync(path.join(REPO_ROOT, '.env')) && /ANTHROPIC_API_KEY=.+/.test(fs.readFileSync(path.join(REPO_ROOT, '.env'), 'utf8')) ? 'có' : 'không',
  }
}

const fmt = (d) =>
  new Intl.DateTimeFormat('sv-SE', { timeZone: 'Asia/Ho_Chi_Minh', dateStyle: 'short', timeStyle: 'medium' }).format(d)

/**
 * @param {{id:string,title:string,setup?:string,cleanup?:string,notes?:string[],
 *          steps:{action:string,expect:string,run:(ctx:any)=>Promise<{ok:boolean,actual:string}|void>,shot?:boolean}[]}} tc
 */
export async function runTest(tc) {
  const dir = path.join(REPORTS_ROOT, tc.id)
  // Fresh run: clear previous artifacts but keep the test script itself (<ID>.mjs).
  if (fs.existsSync(dir))
    for (const f of fs.readdirSync(dir)) if (f !== `${tc.id}.mjs`) fs.rmSync(path.join(dir, f), { recursive: true, force: true })
  const start = new Date()
  const results = []
  const notes = [...(tc.notes ?? [])]
  let blocked = null
  let ev
  try {
    ev = await startEvidence(tc.id)
    if (tc.setup) sh(ev.dir, tc.setup)
  } catch (e) {
    blocked = `Không chuẩn bị được môi trường: ${String(e.message || e).split('\n')[0]}`
  }
  const ctx = { ...(ev ?? {}), dir, notes, sh: (c) => sh(dir, c) }
  if (!blocked) {
    for (const [i, s] of tc.steps.entries()) {
      const n = i + 1
      await ev.caption(`Bước ${n}: ${s.action}`)
      let r
      try {
        r = (await s.run(ctx)) ?? { ok: true, actual: 'Như mong đợi' }
      } catch (e) {
        r = { ok: false, actual: `Lỗi khi thực hiện: ${String(e.message || e).split('\n')[0]}` }
      }
      const shot = s.shot === false ? null : await ev.shot(`buoc-${n}-${s.action}`).catch(() => null)
      results.push({ n, action: s.action, expect: s.expect, actual: r.actual, ok: r.ok, shot })
      console.log(`${r.ok ? '✅' : '❌'} ${tc.id} bước ${n}: ${r.actual}`)
    }
  }
  let video = null
  if (ev) video = (await ev.finish()).video
  try {
    if (tc.cleanup) sh(dir, tc.cleanup)
  } catch (e) {
    notes.push(`Dọn dẹp lỗi: ${String(e.message || e).split('\n')[0]}`)
  }
  const end = new Date()
  const verdict = blocked ? '⛔ Bị chặn' : results.every((r) => r.ok) ? '✅ Đạt' : '❌ Không đạt'
  fs.mkdirSync(path.join(dir, 'logs'), { recursive: true })
  fs.writeFileSync(path.join(dir, 'logs', 'checks.json'), JSON.stringify({ verdict, results, notes }, null, 2))
  writeReport(dir, tc, { verdict, results, notes, blocked, video, start, end, env: env() })
  console.log(`${verdict} — ${tc.id} → ${path.relative(REPO_ROOT, dir)}/report.md`)
  return verdict
}

function writeReport(dir, tc, r) {
  const esc = (s) => String(s).replace(/\|/g, '\\|').replace(/\n/g, '<br>')
  const shots = fs.existsSync(path.join(dir, 'screenshots')) ? fs.readdirSync(path.join(dir, 'screenshots')).sort() : []
  const fails = r.results.filter((x) => !x.ok)
  const L = [
    `# Báo cáo kiểm thử — ${tc.id}: ${tc.title}`,
    '',
    '| Mục | Giá trị |',
    '|---|---|',
    `| Test case | [${tc.id}](../../docs/07-verification/test_cases/${tc.id}.md) |`,
    `| Kết luận | **${r.verdict}** |`,
    `| Thời gian chạy | ${fmt(r.start)} → ${fmt(r.end).slice(11)} (UTC+7) |`,
    '| Người / agent thực hiện | Claude Code (agent), script Playwright tự động |',
    `| Commit | \`${r.env.commit}\` |`,
    `| Môi trường | localhost · web ${WEB_URL} · API ${API_URL} · ${r.env.os} · Docker ${r.env.docker} · ANTHROPIC_API_KEY: ${r.env.key} |`,
    `| Script | [${tc.id}.mjs](${tc.id}.mjs) |`,
    '',
  ]
  if (r.blocked) L.push(`> ⛔ ${r.blocked}`, '')
  L.push('## Kết quả từng bước', '', '| # | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đạt? | Bằng chứng |', '|---|---|---|---|---|---|')
  for (const x of r.results)
    L.push(`| ${x.n} | ${esc(x.action)} | ${esc(x.expect)} | ${esc(x.actual)} | ${x.ok ? '✅' : '❌'} | ${x.shot ? `[ảnh](${x.shot})` : '—'} |`)
  L.push('', '## Bằng chứng', '', `- Video: ${r.video ? `[${r.video}](${r.video})` : '—'}`, '- Log: [logs/checks.json](logs/checks.json), [logs/browser-console.log](logs/browser-console.log)' + (fs.existsSync(path.join(dir, 'logs', 'setup.log')) ? ', [logs/setup.log](logs/setup.log)' : ''), '- Ảnh:', '')
  for (const s of shots) L.push(`  ![${s}](screenshots/${s})`, '')
  L.push('## Lỗi phát hiện', '')
  if (fails.length) {
    L.push('| # | Mô tả | Mức độ | Bước | Bằng chứng |', '|---|---|---|---|---|')
    fails.forEach((x, i) => L.push(`| ${i + 1} | ${esc(x.actual)} | (cần phân loại) | ${x.n} | ${x.shot ? `[ảnh](screenshots/${path.basename(x.shot)})` : '—'} |`))
  } else L.push('Không có.')
  L.push('', '## Ghi chú và sai lệch so với test case', '')
  L.push(...(r.notes.length ? r.notes.map((n) => `- ${n}`) : ['Không có.']), '')
  fs.writeFileSync(path.join(dir, 'report.md'), L.join('\n'))
}
