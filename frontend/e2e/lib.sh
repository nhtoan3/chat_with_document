# shellcheck shell=bash
# Shared helpers for test-case scripts (docs/07-verification/test_cases/).
# Usage inside test_reports/<ID>/steps.sh:   source frontend/e2e/lib.sh
# Every helper talks to the LOCAL stack only (make dev).

API_URL=${API_URL:-http://localhost:8000}
WEB_URL=${WEB_URL:-http://localhost:5173}
REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
FIXTURES="$REPO_ROOT/backend/tests/fixtures/pdfs"
COMPOSE=(docker compose -f "$REPO_ROOT/docker-compose.yml")
# Generated test files go to test_reports/<ID>/data (TEST_DIR is set by run-cli.mjs).
DATA_DIR="${TEST_DIR:-$REPO_ROOT/test_reports/_tmp}/data"
mkdir -p "$DATA_DIR"

# Run one SQL statement on the local Postgres.
psql_q() { "${COMPOSE[@]}" exec -T postgres psql -U cwd -d cwd -v ON_ERROR_STOP=1 -P pager=off -c "$1"; }

# Fail fast if the local stack is not up.
check_stack() {
  curl -fsS "$API_URL/healthz" >/dev/null || { echo "API $API_URL không phản hồi — chạy 'make dev'"; return 1; }
  curl -fsS -o /dev/null "$WEB_URL" || { echo "Web $WEB_URL không phản hồi — chạy 'make dev'"; return 1; }
  echo "Stack OK: API $API_URL · Web $WEB_URL"
}

# Remove every document, job, chunk and qa_log row (S3 objects are left orphaned; harmless locally).
reset_data() { psql_q "TRUNCATE documents, ingestion_jobs, chunks, qa_log RESTART IDENTITY CASCADE;"; }

# upload <file>... — POST /api/v1/documents; prints body and HTTP status.
upload() {
  local args=()
  for f in "$@"; do args+=(-F "files=@$f"); done
  curl -sS -w '\nHTTP %{http_code}\n' -X POST "$API_URL/api/v1/documents" "${args[@]}"
}

seed_samples() { upload "$FIXTURES"/sample/*.pdf; }

# GET /api/v1/documents, pretty-printed.
docs() { curl -sS "$API_URL/api/v1/documents" | jq; }
counts() { curl -sS "$API_URL/api/v1/documents" | jq -c '.counts'; }

# wait_idle [timeout_s=300] — wait until no document is queued/processing.
wait_idle() {
  local timeout=${1:-300} t=0 p
  while :; do
    p=$(curl -sS "$API_URL/api/v1/documents" | jq '.counts.processing')
    [ "$p" = "0" ] && break
    if [ "$t" -ge "$timeout" ]; then echo "TIMEOUT sau ${timeout}s, counts=$(counts)"; return 1; fi
    sleep 2; t=$((t + 2))
  done
  echo "Hết tài liệu đang xử lý sau ~${t}s · counts=$(counts)"
}

# ask "<question>" — POST /api/v1/ask; prints body, HTTP status and total time.
ask() {
  curl -sS -w '\nHTTP %{http_code} · %{time_total}s\n' -X POST "$API_URL/api/v1/ask" \
    -H 'content-type: application/json' -d "$(jq -n --arg q "$1" '{question: $q}')"
}

# make_pdf <kind> <out> — generate special test files.
#   big21mb  : 21 MB file with a %PDF- header (rejected as file_too_large)
#   big20mb  : 20 MB - 1 KB file with a %PDF- header (accepted at upload, fails later as corrupted)
#   pages301 : valid 301-page PDF (too_many_pages)
#   pages50  : valid 50-page Vietnamese text PDF (NFR-003)
make_pdf() {
  local kind=$1 out=$2
  case "$kind" in
    big21mb) python3 -c "import sys;open(sys.argv[1],'wb').write(b'%PDF-1.4\n'+b'0'*(21*1024*1024))" "$out" ;;
    big20mb) python3 -c "import sys;open(sys.argv[1],'wb').write(b'%PDF-1.4\n'+b'0'*(20*1024*1024-1024))" "$out" ;;
    pages301)
      (cd "$REPO_ROOT/backend" && .venv/bin/python -c \
        "import sys;from tests.fixtures.make_pdfs import many_pages_pdf;open(sys.argv[1],'wb').write(many_pages_pdf(301))" "$out") ;;
    pages50)
      (cd "$REPO_ROOT/backend" && .venv/bin/python -c "
import sys
from tests.fixtures.make_pdfs import text_pdf
body = ('Điều {n}. Bên bán có trách nhiệm giao hàng đúng hạn, đúng chất lượng và số lượng đã thỏa thuận. '
        'Trường hợp chậm giao hàng, bên bán chịu phạt theo quy định tại hợp đồng khung. ') * 8
open(sys.argv[1], 'wb').write(text_pdf([body.format(n=i + 1) for i in range(50)]))" "$out") ;;
    *) echo "make_pdf: kind không hợp lệ: $kind"; return 2 ;;
  esac
  ls -l "$out"
}
