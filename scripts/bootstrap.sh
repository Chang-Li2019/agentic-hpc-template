#!/usr/bin/env bash
# Turn this template into a live project. Run once, from the repo root.
#   scripts/bootstrap.sh "SJLIFE RVAT cardiotoxicity"
set -Eeuo pipefail
NAME="${1:?usage: bootstrap.sh \"<project name>\"}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for t in PLAN PROGRESS DECISIONS; do
  if [[ -f "docs/${t}.md" ]]; then
    echo "docs/${t}.md exists — leaving it alone"
  else
    cp "docs/${t}.template.md" "docs/${t}.md"
    echo "created docs/${t}.md"
  fi
done

sed -i.bak "s|<PROJECT NAME>|${NAME}|g; s|<YYYY-MM-DD>|$(date -u +%Y-%m-%d)|g" docs/PLAN.md && rm -f docs/PLAN.md.bak

if [[ ! -d .git ]]; then
  git init -q && echo "initialized git repo"
fi

mkdir -p steps/00_scratch logs results
touch logs/.gitkeep

echo
echo "Project '${NAME}' bootstrapped."
echo "Next: open docs/PLAN.md and start a planning session. Do not build until status is AGREED."
