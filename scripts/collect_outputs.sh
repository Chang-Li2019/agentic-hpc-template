#!/usr/bin/env bash
# Promote a verified artifact into results/ with provenance.
# Nothing enters results/ by hand. (CLAUDE.md Rule 8)
#   scripts/collect_outputs.sh steps/03_assoc/out/top_hits.tsv table1_top_hits.tsv
set -Eeuo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel)"
SRC="${1:?usage: collect_outputs.sh <source_path> [dest_name]}"
DEST_NAME="${2:-$(basename "$SRC")}"
RESULTS="${REPO_ROOT}/results"
MANIFEST="${RESULTS}/MANIFEST.tsv"
mkdir -p "$RESULTS"

[[ -s "$SRC" ]] || { echo "missing or empty: $SRC" >&2; exit 1; }

if [[ ! -f "$MANIFEST" ]]; then
  printf 'artifact\tsource\tstep\tcommit\tutc_time\tsha256\tbytes\n' > "$MANIFEST"
fi

STEP="$(echo "$SRC" | sed -nE 's#.*steps/([^/]+)/.*#\1#p')"; STEP="${STEP:-unknown}"
COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo none)"
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  COMMIT="${COMMIT}-dirty"
  echo "WARNING: working tree is dirty — this artifact is not cleanly reproducible" >&2
fi
SHA="$(sha256sum "$SRC" | cut -d' ' -f1)"
SIZE="$(stat -c%s "$SRC")"

cp "$SRC" "${RESULTS}/${DEST_NAME}"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$DEST_NAME" "$SRC" "$STEP" "$COMMIT" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$SHA" "$SIZE" >> "$MANIFEST"

echo "promoted -> results/${DEST_NAME}  (step=${STEP} commit=${COMMIT})"
