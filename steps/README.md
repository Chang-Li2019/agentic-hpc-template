# Steps

One directory per analysis step, named `NN_short_name`, created only via:

```bash
scripts/new_step.sh 03 assoc
```

Each contains:
- `README.md` — purpose, inputs, outputs, runtime tier, smoke test, caveats
- `run.sh` — the entire step, sourcing `scripts/lib/common.sh`
- `out/` — step outputs (gitignored; promote to `results/` when verified)

`00_scratch/` is the only place ad-hoc exploration is allowed, and nothing in it
may inform a decision without first being promoted into a numbered step.
