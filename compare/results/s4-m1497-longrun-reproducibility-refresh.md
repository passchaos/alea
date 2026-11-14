# S4-M1497 Long-Run Refresh and Reproducibility Notes

Date: 2026-11-14

## Change

Docs and evidence only: the reproducibility matrix now records the
stream-preservation contract of the extreme-parameter batch, and the 10M
long-run sweep was re-run against the current tree.

## Reproducibility Matrix

Two rows were added to the stable-output table:

- the extreme-parameter sampler guards (triangular `√floatMax` range check,
  Kumaraswamy `-expm1` complement, Von Mises `N(μ, 1/κ)` huge-κ limit, Rice
  `hypot` fallback, Inverse-Gaussian `√floatMax/1600` guard) only change
  behavior above their thresholds and keep the normal-parameter streams
  identical, with the A/B checksums recorded in the row;
- the CDF/quantile/moment helpers are deterministic and consume no
  randomness, and the Dirichlet huge-alpha rescale only applies when the
  gamma total overflows f64 (the finite-total path is byte-identical).

## Long-Run Refresh

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)`. The huge-parameter gates reproduce the
S4-M1478 values exactly:

- `long hypergeometric huge cdf: below=0.252459 (cdf 0.252492)
  above=0.747386 (cdf 0.747508)`,
- `long hypergeometric huge rare cdf: empirical=0.526723
  (cdf 0.526562)`.

## Validation

- `zig build test --summary all` passes 927/927 (native `alea-tests` 908/908);
  the change is docs-only.
- `zig build roadmapcheck` and the doc checks pass.
- The aggregate `validate-all` evidence remains current from S4-M1496
  (124/124 steps, 1843/1843 tests).
