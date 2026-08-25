# Logs

Every run writes here automatically via `scripts/lib/common.sh`.

Filename: `<step>__<tier>__<UTC timestamp>.log`
LSF adds `.lsf.out` / `.lsf.err` alongside.

**Contents are gitignored on purpose** — logs are large, machine-specific, and
often contain paths to protected data. What matters long-term goes in
`docs/DECISIONS.md`, not here.

Read them with `scripts/logtail.sh` rather than `ls | tail`.
