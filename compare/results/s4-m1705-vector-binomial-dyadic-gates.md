# S4-M1705 Vector Binomial Dyadic Probability Gates

Date: 2026-11-16

## Change

The vector binomial dyadic pmf gate only covered `p = 0.25` (`m = 2,
k = 1`). The packed kernel also has `m = 2, k = 3`, `m = 3` (both `k`), and
`m = 4` mask branches, plus the `p > 0.5` complement subtraction. Generalized
`checkVectorBinomialBins(rng, vectors, p, label)` and added gates for
`p = 0.0625`, `0.125`, `0.25`, `0.375`, and `0.75` (`trials = 40`, 8 bins of
width 5). Tooling-only; no library code changed.

This follows the S4-M1701 finding that the analogous geometric kernel had a
multi-word accumulation bug that the old single-`p` gate missed.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` passes all
  long gates, including the five dyadic binomial gates, and prints
  `distlongcheck ok (10000000 samples)`.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `tools/distcheck.zig`: the parameterized dyadic binomial gate and five
  probability calls.
