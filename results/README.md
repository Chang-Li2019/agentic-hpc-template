# Results

Only **promoted, verified** artifacts live here, and only via:

```bash
scripts/collect_outputs.sh steps/03_assoc/out/top_hits.tsv table1_top_hits.tsv
```

`MANIFEST.tsv` records artifact, source path, step, git commit, UTC time, sha256,
and size for every file. If a file is here but not in the manifest, it was copied
by hand and cannot be trusted — regenerate it properly.

A `-dirty` commit in the manifest means the working tree had uncommitted changes
when the artifact was promoted. Do not put a `-dirty` artifact in a manuscript.
