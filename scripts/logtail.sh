#!/usr/bin/env bash
# Read the log before you guess. (CLAUDE.md Rule 5)
#   scripts/logtail.sh              newest log, last 80 lines
#   scripts/logtail.sh 03_assoc     newest log for that step
#   scripts/logtail.sh --errors     errors across all logs
#   scripts/logtail.sh --list       recent logs
set -Eeuo pipefail
LOG_DIR="$(git rev-parse --show-toplevel)/logs"
N="${LINES_TO_SHOW:-80}"

case "${1:-}" in
  --errors)
    grep -nEi 'error|traceback|killed|segfault|oom|exit code [1-9]|command not found' \
      "$LOG_DIR"/*.log 2>/dev/null | tail -60 || echo "no errors found"
    ;;
  --list)
    ls -1t "$LOG_DIR"/*.log 2>/dev/null | head -20 || echo "no logs yet"
    ;;
  "")
    f="$(ls -1t "$LOG_DIR"/*.log 2>/dev/null | head -1)" || { echo "no logs yet"; exit 0; }
    echo "== $f"; tail -n "$N" "$f"
    ;;
  *)
    f="$(ls -1t "$LOG_DIR"/${1}*.log 2>/dev/null | head -1)" || { echo "no logs for $1"; exit 0; }
    echo "== $f"; tail -n "$N" "$f"
    ;;
esac
