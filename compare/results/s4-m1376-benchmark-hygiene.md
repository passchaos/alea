# S4-M1376 — Benchmark comparison hygiene and regression-hunt method

## Goal

Record the regression-hunt method that found the real S4-M1370 skew-normal
regression and the focused A/B checks that showed the other full-suite
deltas were context noise, so future performance batches can separate real
regressions from benchmark-local variance.

## Method

1. Run a full-suite benchmark at the current tree and at a recorded baseline
   tree, then sort rows by relative change.
2. Treat full-suite deltas as **screening signals only**: a single process
   run contains every benchmark row, so code layout, I-cache state, and
   thermal drift can move unrelated rows by 10-30%.
3. Confirm each flagged row with a focused `bench -- <filter>` A/B in the
   same session, and when a specific commit is suspected, build both commits
   in `git worktree` checkouts and run the same focused filter.

## Findings

- **Real regression**: `alea skew-normal` fell about 13% (575M → 500M) and
  scalar direct about 14% (670M → 565M) between S4-M1369 and S4-M1370. A
  worktree bisect at S4-M1366/S4-M1369/S4-M1370/S4-M1371 isolated it to the
  S4-M1370 vector Kent Wood tail, which was reverted in S4-M1375; the row is
  restored to 575-593M / 660-676M.
- **Verified noise** (focused A/B, baseline `3d8f7fa9` vs current):

| Row | Full-suite delta | Focused baseline | Focused current |
| --- | --- | --- | --- |
| `BufferedLogNormal f32 stddev=1 fast direct` | -30.7% | 407.8M | 401.3M |
| `standard-geometric` | -13.2% | 1658.3M | 1628.2M |
| `fillStandardNormal scalar direct` | -9.9% | 604.2M | 618.6M |

The focused differences are 1-2%, confirming the full-suite deltas were
context effects for these non-dominant rows.

## Consequences

- Future regression hunts must verify flagged rows with focused runs or
  worktree A/B before reverting or rewriting a change.
- Keep the worktree bisect approach for suspected commits: build both trees
  on the same host state and compare the same filter.
- The roadmap and `performance-triage.md` now record both the real
  regression and the noise-verification result.

## Validation

- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes and the 10M long run passes; no source change
  was made in this milestone.
