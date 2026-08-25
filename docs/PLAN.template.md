# Project Plan — <PROJECT NAME>

**Status:** `DRAFT`   <!-- DRAFT -> UNDER_DISCUSSION -> AGREED -> AMENDED(vN) -->
**Owner:** <name>
**Last updated:** <YYYY-MM-DD>

> The agent may not create steps or run jobs while status is not `AGREED`.

---

## 1. Question

One paragraph. What scientific question does this project answer, and for whom?
If you cannot write this without hedging, the project is not ready.

## 2. Hypothesis / expected result

What do you expect to find, and what result would make you abandon this line?

## 3. Data

| Dataset | Cohort | N | Location | Access | Notes |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## 4. Analytic approach

Prose, not bullet soup. Model specification, covariates, multiple-testing
correction, replication strategy. Name the software and version.

## 5. Deliverables

- [ ] Table 1: ...
- [ ] Figure 1: ...
- [ ] Supplementary: ...

## 6. Steps

Each becomes `steps/NN_name/`. Keep the estimate honest — it drives the runtime tier.

| # | Name | Purpose | Inputs | Outputs | Est. runtime | Tier |
|---|---|---|---|---|---|---|
| 01 | ingest | | | | 3 min | local |
| 02 | qc | | | | 15 min | tmux |
| 03 | assoc | | | | 6 h | lsf |

## 7. Open Questions

<!-- Agent appends here. User answers inline under **Answer:**. -->

### Q1 [OPEN] <question>
**Context:**
**Options:**
**Recommendation:**
**Answer:**

## 8. Out of scope

Explicitly list what this project will NOT do. This section prevents scope creep
more reliably than any other part of the plan.

## 9. Amendment log

| Date | Change | Reason |
|---|---|---|
