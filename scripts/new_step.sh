#!/usr/bin/env bash
# Scaffold a new step. Never create step directories by hand.
#   scripts/new_step.sh 03 assoc
set -Eeuo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel)"
NUM="${1:?usage: new_step.sh <NN> <short_name>}"
NAME="${2:?usage: new_step.sh <NN> <short_name>}"
DIR="${REPO_ROOT}/steps/${NUM}_${NAME}"
[[ -e "$DIR" ]] && { echo "already exists: $DIR" >&2; exit 1; }
mkdir -p "$DIR"

cat > "$DIR/README.md" <<EOF
# Step ${NUM} — ${NAME}

**Purpose:** <one sentence: what question does this step answer?>

**Runtime tier:** local   <!-- local (<5min) | tmux (5-20min) | lsf (>20min) -->
**Estimated runtime:** <fill in, or run the smoke test and extrapolate>

## Inputs
| Path | Produced by | Notes |
|---|---|---|
|  |  |  |

## Outputs
| Path | Consumed by | Notes |
|---|---|---|
|  |  |  |

## How to run
\`\`\`bash
scripts/run.sh ${NUM}_${NAME} --smoke     # cheap subset first
scripts/run.sh ${NUM}_${NAME}             # full run
\`\`\`

## Smoke test
<What subset runs in under a minute, and what output proves the step works?>

## Assumptions & caveats
- <what would make this step's output wrong?>

## Decisions
<Link to the docs/DECISIONS.md rows that belong to this step.>
EOF

cat > "$DIR/run.sh" <<'EOF'
#!/usr/bin/env bash
source "$(git rev-parse --show-toplevel)/scripts/lib/common.sh"
banner
assert_not_login_node

SMOKE="${SMOKE:-0}"
[[ "$SMOKE" == "1" ]] && log "SMOKE MODE — subset only, outputs are not publishable"

STEP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${STEP_DIR}/out"; mkdir -p "$OUT_DIR"

# --- inputs -------------------------------------------------------------
# require_file "${REPO_ROOT}/steps/02_qc/out/clean.vcf.gz"

# --- work ---------------------------------------------------------------
log "TODO: implement this step"

# --- verify -------------------------------------------------------------
# require_file "${OUT_DIR}/result.tsv"
log "wrote outputs to ${OUT_DIR}"
EOF

chmod +x "$DIR/run.sh"
mkdir -p "$DIR/out"
cat > "$DIR/out/.gitignore" <<'EOF'
*
!.gitignore
EOF

echo "created $DIR"
echo "next: fill in README.md BEFORE writing run.sh, then add a row to docs/PROGRESS.md"
