# Diagram Prompt

Generated from `docs/PLAN.md` at status `AGREED`. Paste into an image/diagram
tool. Regenerate whenever the plan changes materially.

---

## Prompt

Create a clean, publication-style **statistical genetics analysis flow diagram**
(the CONSORT-like style used in GWAS and epidemiology papers). Vertical top-to-bottom
flow, boxes connected by arrows, exclusions branching to the right.

**Style:** white background, thin dark-grey rectangular boxes with square corners,
sans-serif labels, no drop shadows, no 3D, no gradients, no icons or clip art.
Muted palette — one accent colour only, used for the primary analysis path.
Every box carries its sample count as `N = ...` on its own line.

**Flow to render:**

1. **Source cohorts** — <cohort A, N = ...>; <cohort B, N = ...>
2. **Eligibility** — <criteria>. Excluded (right branch): <reason, n = ...>
3. **Data layers** — <e.g. WGS N = ...; methylation array N = ...; clinical N = ...>
4. **Quality control** — <call rate, MAF, relatedness, ancestry>. Excluded: <n = ...>
5. **Analytic sample** — N = ...
6. **Model** — <e.g. rare-variant burden, SKAT-O, covariates: age, sex, 10 PCs, treatment>
7. **Discovery outputs** — <n genes/CpGs tested; significance threshold>
8. **Replication** — <cohort, N = ...>; <criterion>
9. **Final result** — <what goes in Table 1 / Figure 1>

Label each arrow with the step number from the plan (01, 02, 03 …) so the diagram
maps one-to-one onto `steps/`.

---

## Fill-in checklist

- [ ] Every N is a real number from a real output, not a placeholder
- [ ] Every exclusion box has a reason and a count
- [ ] Step numbers on arrows match `steps/` directory names
- [ ] Replication arm shown, or explicitly marked "no replication"
