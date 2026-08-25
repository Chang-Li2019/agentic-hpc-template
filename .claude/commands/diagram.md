---
description: Regenerate docs/DIAGRAM_PROMPT.md from the current plan
---

Read `docs/PLAN.md` and `docs/PROGRESS.md`. Using
`docs/DIAGRAM_PROMPT.template.md` as the structure, write `docs/DIAGRAM_PROMPT.md`
with every placeholder replaced by real values from the plan and from actual step outputs.

Rules:
- Use real sample counts pulled from step outputs. Where a count is not yet known,
  write `N = TBD (step NN)` rather than inventing a number.
- Arrow labels must match the `steps/` directory numbers exactly.
- Then print the finished prompt in chat so I can paste it straight into a diagram tool.
