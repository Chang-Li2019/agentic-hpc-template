#!/usr/bin/env bash
# Shared helpers. Source this at the top of every step's run.sh:
#   source "$(git rev-parse --show-toplevel)/scripts/lib/common.sh"

set -Eeuo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
LOG_DIR="${REPO_ROOT}/logs"
RESULTS_DIR="${REPO_ROOT}/results"
mkdir -p "$LOG_DIR" "$RESULTS_DIR"

STEP_NAME="${STEP_NAME:-$(basename "$(dirname "${BASH_SOURCE[1]:-$0}")")}"
TIER="${TIER:-local}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="${LOG_DIR}/${STEP_NAME}__${TIER}__${STAMP}.log"

# Mirror all stdout/stderr into the central log.
exec > >(tee -a "$LOG_FILE") 2>&1

log()  { printf '[%s] %-5s %s\n' "$(date -u +%H:%M:%SZ)" "INFO"  "$*"; }
warn() { printf '[%s] %-5s %s\n' "$(date -u +%H:%M:%SZ)" "WARN"  "$*"; }
die()  { printf '[%s] %-5s %s\n' "$(date -u +%H:%M:%SZ)" "ERROR" "$*"; exit 1; }

# Fail loudly with context the agent can act on.
trap 'die "step ${STEP_NAME} failed at line ${LINENO}: ${BASH_COMMAND}"' ERR

require_file() { [[ -s "$1" ]] || die "missing or empty required input: $1"; }
require_cmd()  { command -v "$1" >/dev/null || die "command not found: $1 (add it to pixi.toml)"; }

# Guard: refuse to burn a login node.
assert_not_login_node() {
  local h; h="$(hostname -s)"
  if [[ "$h" == *login* || "$h" == *head* ]]; then
    die "refusing to run on login node '$h' — use scripts/run.sh --tier tmux|lsf"
  fi
}

banner() {
  log "step=${STEP_NAME} tier=${TIER} host=$(hostname -s) commit=$(git rev-parse --short HEAD 2>/dev/null || echo none)"
  log "log=${LOG_FILE}"
}

finish() {
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    log "step ${STEP_NAME} completed in ${SECONDS}s"
  else
    printf '[%s] %-5s %s\n' "$(date -u +%H:%M:%SZ)" "ERROR" \
      "step ${STEP_NAME} EXITED ${rc} after ${SECONDS}s — see ${LOG_FILE}"
  fi
}
trap finish EXIT
