#!/usr/bin/env python3
"""Hook codegraph cho agent sdlc-06-build.

--on-start  (SubagentStart): đồng bộ index và nhắc agent dùng codegraph trước khi sửa code.
--on-edit   (PreToolUse Edit|Write): trước khi sửa một file trong backend/app hoặc frontend/src,
            chèn symbol map + danh sách file phụ thuộc của file đó (mỗi file một lần mỗi phiên).
Không bao giờ chặn tool; lỗi codegraph chỉ thành ghi chú.
"""
import hashlib
import json
import os
import subprocess
import sys

CODE_DIRS = ("backend/app/", "frontend/src/")
LIMIT = 6000


def run(args, timeout=60):
    try:
        r = subprocess.run(["codegraph", *args, "--no-color"], capture_output=True, text=True, timeout=timeout)
        return r.returncode, (r.stdout or "") + (r.stderr if r.returncode else "")
    except FileNotFoundError:
        return 127, "codegraph không có trong PATH (npm i -g @colbymchenry/codegraph)"
    except subprocess.TimeoutExpired:
        return 124, "codegraph quá thời gian"


def emit(event, text):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": event, "additionalContext": text[:LIMIT]}}, ensure_ascii=False))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--on-edit"
    try:
        inp = json.load(sys.stdin)
    except ValueError:
        return 0
    cwd = inp.get("cwd") or os.getcwd()
    if mode != "--on-start":
        path = (inp.get("tool_input") or {}).get("file_path") or ""
        rel = os.path.relpath(path, cwd) if os.path.isabs(path) else path
        if not rel.startswith(CODE_DIRS):
            return 0  # ngoài vùng code: im lặng, kể cả khi chưa có index
    if not os.path.isdir(os.path.join(cwd, ".codegraph")):
        emit("SubagentStart" if mode == "--on-start" else "PreToolUse",
             "codegraph: repo chưa có index (.codegraph/). Chạy `codegraph init .` ở gốc repo trước khi sửa code.")
        return 0
    if mode == "--on-start":
        rc, out = run(["sync", cwd], timeout=120)
        note = "" if rc == 0 else f"\n(codegraph sync lỗi: {out.strip()[:300]})"
        emit("SubagentStart",
             "codegraph đã sẵn sàng (MCP server `codegraph`, tool `codegraph_explore`). Trước khi sửa code: gọi "
             "`codegraph_explore` với mô tả task để lấy symbol liên quan và đường gọi; sau khi đổi chữ ký hàm, "
             "kiểm tra ảnh hưởng bằng `codegraph impact <symbol>` (CLI). Mỗi lần Edit/Write một file trong "
             "backend/app hoặc frontend/src, hook sẽ chèn symbol map và file phụ thuộc của file đó." + note)
        return 0
    if not os.path.exists(os.path.join(cwd, rel)):
        return 0  # file mới: chưa có gì trong index
    sid = inp.get("session_id", "nosession")
    seen = os.path.join(cwd, ".sdlc", f"codegraph-seen-{sid[:12]}.txt")
    key = hashlib.sha1(rel.encode()).hexdigest()
    try:
        if key in open(seen).read():
            return 0
        open(seen, "a").write(key + "\n")
    except FileNotFoundError:
        os.makedirs(os.path.dirname(seen), exist_ok=True)
        open(seen, "w").write(key + "\n")
    rc, out = run(["node", rel, "--symbols-only", "-p", cwd])
    if rc != 0:
        emit("PreToolUse", f"codegraph node {rel} lỗi: {out.strip()[:300]}")
        return 0
    emit("PreToolUse", f"codegraph — file sắp sửa `{rel}`: symbol và nơi dùng (kiểm tra caller trước khi đổi chữ ký)\n{out.strip()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
