# agentic-hpc-template

A project skeleton for running coding agents on computational-biology work on an
**LSF HPC cluster**. Clone it, bootstrap it, and every new project starts with the
same plan-first discipline, the same runtime tiering, and the same reproducibility
contract — on any machine.

The core idea: **the agent's memory is the filesystem, not the chat window.**
Every rule below exists to move state out of a transcript that disappears and into
files that survive.

---

## Use it

```bash
git clone <your-fork> my-project && cd my-project
rm -rf .git

scripts/bootstrap.sh "SJLIFE RVAT cardiotoxicity"
pixi install

claude          # then run /plan
```

Then, in order:

1. **`/plan`** — the agent reads `docs/PLAN.md`, names its weakest part, and appends
   `[OPEN]` questions. You answer them **inline in the file**. Repeat until the plan
   status line says `AGREED`. No code exists yet, on purpose.
2. **`/diagram`** — generates `docs/DIAGRAM_PROMPT.md`, a paste-ready prompt for a
   statistical-genetics style flow diagram. If the diagram is confusing, the plan is
   confusing; go back to step 1.
3. **Build** — `scripts/new_step.sh 01 ingest`, README first, then `run.sh`.
   Smoke test, then full run at the right tier.
4. **`/status`** — at the start of every session. It catches the case where
   `PROGRESS.md` and the actual disk state disagree.

---

## Layout

```
CLAUDE.md                  the operating protocol — the important file
pixi.toml / pixi.lock      environment contract (lock file is committed)

docs/
  PLAN.md                  question, data, approach, steps, open questions
  PROGRESS.md              per-step status, job IDs, blockers, next action
  DECISIONS.md             append-only log of non-obvious fixes
  DIAGRAM_PROMPT.md        generated prompt for the flow diagram

steps/NN_name/
  README.md                purpose, I/O, tier, smoke test, caveats
  run.sh                   the whole step, sourcing scripts/lib/common.sh
  out/                     step outputs (gitignored)

scripts/
  run.sh                   tier dispatcher: local | tmux | bsub
  new_step.sh              scaffolds a step
  logtail.sh               newest log / errors across all logs
  collect_outputs.sh       promote an artifact into results/ with provenance
  lib/common.sh            logging, guards, fail-fast traps

logs/                      central logs (contents gitignored)
results/                   promoted artifacts + MANIFEST.tsv

.claude/
  agents/                  executor (Sonnet) · scout (Haiku) · reviewer (Opus)
  commands/                /plan · /status · /diagram
```

---

## The ten rules, in one line each

Full text in [`CLAUDE.md`](CLAUDE.md).

1. No building until the plan says `AGREED`.
2. Questions go in `PLAN.md`, answered inline — chat is ephemeral, files are not.
3. Every action leaves a script behind; nothing important runs only in a shell.
4. Every step has a README written *before* the code works.
5. `PROGRESS.md` is updated in the same turn the state changes.
6. All output goes to `logs/`; read the log before guessing at a failure.
7. Runtime tiering: `<5 min` local, `5–20 min` tmux, `>20 min` bsub. Never on a login node.
8. Route by cognitive load: Opus reasons, Sonnet implements, Haiku looks things up.
9. Only promoted artifacts enter `results/`, only via the collector, always with provenance.
10. `pixi` is the environment; the lock file is committed.

---

## Runtime tiers

```bash
scripts/run.sh 01_ingest                              # tier read from step README
scripts/run.sh 02_qc   --tier tmux                    # survives disconnect
scripts/run.sh 03_assoc --tier lsf --mem 32000 --cores 8 --queue standard
scripts/run.sh 03_assoc --smoke                       # cheap subset first, always
```

Set `LSF_QUEUE` and `LSF_PROJECT` in your shell profile so you stop typing them.

After `bsub`, the dispatcher prints the job ID and tells the agent to record it in
`PROGRESS.md` and **stop polling** — an agent watching `bjobs` in a loop burns
context and tells you nothing a single check wouldn't.

---

## Adapting it

The template encodes opinions. Change them deliberately, in `CLAUDE.md`, not by
quietly ignoring them:

- **Not LSF?** Only `scripts/run.sh` (the `lsf` case) and Rule 6 need to change.
- **Different tier thresholds?** Edit the table in Rule 6 — the dispatcher reads
  the tier from each step's README, so the thresholds live in one place.
- **More agents?** Add to `.claude/agents/`. Keep the roster small; five to seven
  scoped specialists work better than a sprawl.

The one rule not worth relaxing is Rule 2. Every reproducibility failure in
practice traces back to a command that was run once, in a terminal, and never
written down.
