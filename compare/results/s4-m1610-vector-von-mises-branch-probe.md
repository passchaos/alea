# S4-M1610 Vector von Mises Per-Lane Branch Probe (Rejected)

Date: 2026-11-15

## Hypothesis

The packed circular von Mises Best–Fisher loop evaluates the slow test
`log(c/ub) + 1 − c >= 0` for all four lanes and `acos(f)` for every lane when
any lane accepts. Computing the log only for the lanes that fail the cheap
squeeze (`active & ~fast`) and `acos` only for accepted lanes should remove
the unused transcendental work.

## Probe

Replaced the unconditional vector `slow` expression with a per-lane
`if (needs_slow[lane])` log evaluation, and the vector `@select`-based
`mu + sign*acos(f)` with a per-lane `if (accept[lane])` assignment. Same
period A/B on `alea-throughput -- 16777216 "mises"`:

| Row | Packed loop (baseline) | Per-lane branches |
| --- | --- | --- |
| `alea vector von mises f64x4` | 6.8 M vectors/s | 5.9 M vectors/s |
| `alea von mises` | 37.0-38.4 M samples/s | 37.0 M samples/s |

The per-lane variant is 13% slower on the vector row (the scalar row is
unchanged), and the vector checksum changes
(`13426811416932291154` -> `13426811416928194426`).

## Why

The unconditional vector expressions lower to straight-line scalarized code
that LLVM schedules across lanes; the per-lane branches and vector-lane
indexing cost more than the saved `log`/`acos` calls, and the branchy
structure disrupts the rejection-loop scheduling. This is consistent with
S4-M1585's finding that extra per-lane bookkeeping in the vector geometry
loops costs more than it saves.

## Decision

Rejected and reverted; the packed circular von Mises loop stays. The rebuilt
baseline reproduces the checksum `13426811416932291154` at 6.8M vectors/s.
The circular vector row remains a documented gap (27-28M samples/s against
the 37-40M scalar sampler) that needs a genuinely dense vector
transcendental or a layout-stable lane scheme.

## Validation

- `git diff` after the revert is empty; the tree is clean.
- Benchmark/docs-only: no library code, sampling stream, or public API
  changed.
