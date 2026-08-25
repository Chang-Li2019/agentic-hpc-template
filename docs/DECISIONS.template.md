# Decision Log

Append-only. One line per non-obvious decision or fix. Newest at the bottom.
Purpose: never debug the same thing twice, and never wonder in six months why
a threshold is what it is.

| Date | Step | Decision / fix | Why |
|---|---|---|---|
| 2026-01-01 | 02_qc | MAF cutoff 0.01, not 0.005 | power sim showed <20% power below 0.01 at our N |
| 2026-01-01 | 03_assoc | bsub needs `-R "rusage[mem=32000]"` | OOM-killed at 16G, see logs/03_assoc__lsf__*.log |
