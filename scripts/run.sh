#!/usr/bin/env bash
# Dispatcher: runs a step at the right runtime tier.
#
#   scripts/run.sh 03_assoc                     # tier from the step's README
#   scripts/run.sh 03_assoc --tier tmux
#   scripts/run.sh 03_assoc --tier lsf --mem 32000 --cores 8 --queue standard
#   scripts/run.sh 03_assoc --smoke             # passes SMOKE=1 to run.sh
#
# Tier rules (see CLAUDE.md Rule 6):
#   local  < 5 min       5-20 min  tmux       > 20 min  lsf

set -Eeuo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel)"

STEP="${1:?usage: run.sh <step_dir_name> [--tier local|tmux|lsf] [--smoke] [lsf opts]}"; shift || true
STEP_DIR="${REPO_ROOT}/steps/${STEP}"
[[ -d "$STEP_DIR" ]] || { echo "no such step: $STEP_DIR" >&2; exit 1; }
[[ -x "$STEP_DIR/run.sh" ]] || { echo "not executable: $STEP_DIR/run.sh" >&2; exit 1; }

TIER=""; SMOKE=0
MEM="16000"; CORES="1"; QUEUE="${LSF_QUEUE:-standard}"; PROJECT="${LSF_PROJECT:-}"; WALL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier)    TIER="$2"; shift 2 ;;
    --smoke)   SMOKE=1; shift ;;
    --mem)     MEM="$2"; shift 2 ;;
    --cores)   CORES="$2"; shift 2 ;;
    --queue)   QUEUE="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --wall)    WALL="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

# Fall back to the tier declared in the step README.
if [[ -z "$TIER" ]]; then
  TIER="$(grep -iEm1 '^\*\*Runtime tier:\*\*' "$STEP_DIR/README.md" 2>/dev/null \
          | grep -oiE '\b(local|tmux|lsf)\b' | head -1 | tr 'A-Z' 'a-z' || true)"
  TIER="${TIER:-local}"
  echo "tier not given; using '${TIER}' from ${STEP}/README.md"
fi

export STEP_NAME="$STEP" TIER SMOKE
LOGDIR="${REPO_ROOT}/logs"; mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

case "$TIER" in
  local)
    echo ">> local: $STEP (smoke=$SMOKE)"
    exec pixi run bash "$STEP_DIR/run.sh"
    ;;

  tmux)
    command -v tmux >/dev/null || { echo "tmux not available" >&2; exit 1; }
    SESSION="${STEP}_${STAMP}"
    tmux new-session -d -s "$SESSION" \
      "cd '$REPO_ROOT' && STEP_NAME='$STEP' TIER=tmux SMOKE=$SMOKE pixi run bash '$STEP_DIR/run.sh'; echo; echo '--- finished, press any key ---'; read -n1"
    echo ">> tmux session: $SESSION"
    echo "   attach:  tmux attach -t $SESSION"
    echo "   detach:  Ctrl-b d"
    echo "   log:     scripts/logtail.sh $STEP"
    ;;

  lsf)
    command -v bsub >/dev/null || { echo "bsub not available — are you on the cluster?" >&2; exit 1; }
    JOBNAME="${STEP}_${STAMP}"
    OUT="${LOGDIR}/${STEP}__lsf__${STAMP}.lsf.out"
    ERR="${LOGDIR}/${STEP}__lsf__${STAMP}.lsf.err"
    BSUB_ARGS=( -J "$JOBNAME" -q "$QUEUE" -n "$CORES"
                -R "rusage[mem=${MEM}]" -R "span[hosts=1]"
                -o "$OUT" -e "$ERR" )
    [[ -n "$PROJECT" ]] && BSUB_ARGS+=( -P "$PROJECT" )
    [[ -n "$WALL"    ]] && BSUB_ARGS+=( -W "$WALL" )

    JOBID="$(bsub "${BSUB_ARGS[@]}" \
      "cd '$REPO_ROOT' && STEP_NAME='$STEP' TIER=lsf SMOKE=$SMOKE pixi run bash '$STEP_DIR/run.sh'" \
      | grep -oE '[0-9]+' | head -1)"

    echo ">> submitted $STEP as job $JOBID (queue=$QUEUE cores=$CORES mem=${MEM}MB)"
    echo "   status:  bjobs $JOBID"
    echo "   kill:    bkill $JOBID"
    echo "   stdout:  $OUT"
    echo
    echo "!! Record job $JOBID in docs/PROGRESS.md now, then stop polling."
    ;;

  *) echo "unknown tier: $TIER" >&2; exit 1 ;;
esac
