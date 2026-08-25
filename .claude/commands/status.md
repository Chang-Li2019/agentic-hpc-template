---
description: Where does this project actually stand?
---

Delegate the lookups to the `scout` agent, then report:

1. Plan status, and any `[OPEN]` questions blocking work.
2. Every step and its status from `docs/PROGRESS.md`.
3. For each `RUNNING` step, the job state (`bjobs <id>`).
4. Any step whose `PROGRESS.md` status disagrees with what is actually on disk —
   this is the most important thing to catch.
5. Recent errors: `scripts/logtail.sh --errors`.

End with the single next action, and nothing else.
