# Agent Operating Protocol

You are working inside a computational-biology project on an **LSF HPC cluster**.
These rules are not suggestions. Violating them is a defect, even if the analysis is correct.

---

## Rule 0 — Plan before you build

Do **not** write analysis code, create steps, or run jobs until `docs/PLAN.md`
has status `AGREED`.

Your first action in a new project is to read `docs/PLAN.md`, ask what you need
to know, and refine it. Building without an agreed plan is the single most
expensive failure mode here.

## Rule 1 — Questions live in the plan file, never only in chat

When you need a decision from the user:

1. Append a block to the `## Open Questions` section of `docs/PLAN.md`:

   ```
   ### Q7 [OPEN] Which covariates go in the null model?
   **Context:** SJLIFE has attained age, sex, 10 genetic PCs, and treatment exposures.
   **Options:** (a) minimal (age, sex, PCs) (b) + treatment (c) + treatment × age
   **Recommendation:** (b) — treatment is a confounder, not a mediator, for this aim.
   **Answer:**
   ```

2. Tell the user in chat: *"3 open questions in PLAN.md — Q7, Q8, Q9."*
3. The user answers **inline in the file** under `**Answer:**`.
4. You then flip `[OPEN]` → `[RESOLVED]`, and propagate the answer into the
   relevant `## Steps` entry. Never leave a resolved answer stranded in the
   Q&A section — the step definition must change too.

Chat is ephemeral. The file is the record.

## Rule 2 — Every action leaves a script behind

**Never run a multi-line analysis command directly in the shell.** If it matters
enough to run, it matters enough to be a file.

- All work happens in `steps/NN_short_name/`.
- Create a new step with `scripts/new_step.sh NN short_name` — never by hand.
- Every step directory contains at minimum `run.sh` and `README.md`.
- One-off exploration is allowed **only** in `steps/00_scratch/`, and anything
  that informs a decision must be promoted into a real step before you move on.

Test: *if the user's laptop died right now, could a stranger reproduce every
number in `results/` from the repo alone?* If no, you broke this rule.

## Rule 3 — Every step has a README.md

`steps/NN_name/README.md` must state, in plain prose:

- **Purpose** — what question this step answers, in one sentence
- **Inputs** — exact paths, with the step that produced them
- **Outputs** — exact paths, and what downstream step consumes them
- **How to run** — the literal command
- **Runtime tier** — `local` / `tmux` / `lsf`, and why
- **Assumptions & caveats** — what would invalidate this step
- **Smoke test** — the cheap subset that proves it works before the full run

Write it *before* `run.sh` works. It is a design document, not documentation.

## Rule 4 — Progress tracker is updated as you go

`docs/PROGRESS.md` is the single source of truth for state. Update it
**in the same turn** that the state changes, not at the end of a session.

Status vocabulary — use exactly these:

| Status | Meaning |
|---|---|
| `TODO` | defined in plan, not started |
| `WIP` | in progress, includes % complete |
| `SMOKE` | smoke test running or under review |
| `RUNNING` | full job submitted, with job ID |
| `DONE` | outputs exist, verified, README accurate |
| `BLOCKED` | waiting on a `[OPEN]` question or an upstream failure |
| `FAILED` | ran, produced wrong or no output, cause logged |

Every `RUNNING` row carries its LSF job ID. Every `BLOCKED` row names what
blocks it. Every `FAILED` row links its log file.

## Rule 5 — Centralized logging, and read the log before you guess

All stdout/stderr goes to `logs/`, named `<step>__<tier>__<UTC timestamp>.log`.
`scripts/lib/common.sh` handles this — source it, don't reinvent it.

**When anything fails, your first action is to read the log file, not to
re-run the command and not to speculate about the cause.**

```bash
scripts/logtail.sh              # newest log
scripts/logtail.sh 03_rvat      # newest log for that step
scripts/logtail.sh --errors     # grep ERROR/Traceback/Killed across all logs
```

Append a one-line entry to `docs/DECISIONS.md` for every non-obvious fix, so the
same bug is never re-debugged from scratch.

## Rule 6 — Runtime tiering (LSF)

Pick the tier by **expected wall time**, and say which tier you picked and why
before you run anything.

| Expected time | Tier | How |
|---|---|---|
| < 5 min | `local` | run directly on the current node |
| 5–20 min | `tmux` | `scripts/run.sh --tier tmux` — survives disconnect |
| > 20 min, or any parallel/array work | `lsf` | `scripts/run.sh --tier lsf` → `bsub` |

Hard rules:
- **Never run anything > 5 min on a login node.** Ever.
- If you cannot estimate the runtime, run the smoke test first and extrapolate.
- After `bsub`, record the job ID in `docs/PROGRESS.md` immediately, then stop
  and hand control back. Do not poll in a loop.

## Rule 7 — Model routing

Match the model to the cognitive load. Delegate via the subagents in
`.claude/agents/`.

| Work | Route to |
|---|---|
| Plan design, statistical reasoning, debugging a wrong result, reviewing an aim | **Opus** (main session) |
| Implementing an agreed step, writing `run.sh`, refactoring, plotting | `executor` (**Sonnet**) |
| Grepping logs, listing files, checking outputs exist, formatting tables | `scout` (**Haiku**) |
| Adversarial review of a finished step | `reviewer` (Opus, read-only) |

Delegate mechanical work aggressively — it keeps the main context clean for
the reasoning that actually needs it.

## Rule 8 — Output collection

Analysis outputs stay inside their step directory. Only **promoted** artifacts
go to `results/`, via `scripts/collect_outputs.sh`, which writes
`results/MANIFEST.tsv` recording: artifact, source step, git commit, timestamp,
checksum.

Nothing enters `results/` by hand. If it is not in the manifest, it does not
exist for the manuscript.

## Rule 9 — Environment is pixi, and it is committed

Everything runs inside `pixi run`. Never `pip install` or `conda install` into a
live environment — add the dependency to `pixi.toml`, re-lock, commit the lock
file. `pixi.lock` is the reproducibility contract; it is never gitignored.

## Rule 10 — Diagram prompt

When the plan reaches `AGREED`, generate `docs/DIAGRAM_PROMPT.md` — a
self-contained prompt for an image/diagram tool that renders the analysis as a
**statistical-genetics style flow diagram** (cohorts → QC → genotype/methylation
data → model → outputs, with N at every node). Regenerate it whenever the plan
changes materially. See `docs/DIAGRAM_PROMPT.template.md`.

---

## Session start checklist

1. Read `docs/PLAN.md` — what is the status line?
2. Read `docs/PROGRESS.md` — what is `WIP`, `RUNNING`, `BLOCKED`?
3. Check for `[OPEN]` questions; if any, surface them first.
4. If any step is `RUNNING`, check its job before proposing new work.
5. State the one thing you propose to do next, and wait.

## Session end checklist

1. `docs/PROGRESS.md` reflects reality.
2. Every touched step has an accurate `README.md`.
3. New decisions are in `docs/DECISIONS.md`.
4. Work is committed with a message naming the step.
5. Tell the user the single next action for their next block.
