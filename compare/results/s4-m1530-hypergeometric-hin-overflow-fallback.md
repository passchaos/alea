# S4-M1530 Hypergeometric HIN Overflow Fallback and Variance Gates

Date: 2026-11-15

## Problem

A variance audit of the hypergeometric sampler found that
`hypergeometric(100000, 100, 1000)` panicked. `Hypergeometric.init` selects
the HIN inverse-transform method when the mode is within 10 of the lower
support bound, and the setup computes the PMF at that bound through
`fractionOfProductsOfFactorials`:

```
initial_p = ∏_{i=98901}^{99000} i / ∏_{i=99901}^{100000} i   (true value ~0.37)
```

The running f64 product multiplies 100 factors near `1e5` (about `10^500`)
before the matching divisions, overflows to `inf`, and the setup returned
`error.InvalidParameter`. The unchecked top-level `hypergeometric` helper
uses `catch unreachable`, so the valid parameter set panicked. The same
width of product also made the reusable `Hypergeometric.init` reject valid
parameters, diverging from an exact sampler.

## Change

- `fractionOfProductsOfFactorials` now stops early when the running product
  becomes non-finite or zero, instead of iterating over it.
- `HypergeometricInverseTransform.init` declines (`null`) instead of
  returning `error.InvalidParameter` when the PMF product overflows or
  underflows. `Hypergeometric.init` then falls back to H2PE and finally to
  the exact draw loop.
- This is a documented deviation from local `rand_distr`'s
  `PopulationTooLarge` rejection: valid hypergeometric parameters are now
  sampled exactly instead of rejected or panicking. The
  `distribution-parity-matrix.md` entry records the deviation.
- `distcheck` gains an `expectDiscreteVariance` helper and variance gates for
  the inverse-transform (`100, 30, 10`), H2PE (`5000, 2500, 500` and
  `10000, 1000, 2000`), and draw-loop (`100000, 100, 1000`) paths.

## Audit Evidence

500k/200k-sample variance probe against
`Var = n·p·(1−p)·(N−n)/(N−1)`:

| case | path | mean | variance | relative error |
| --- | --- | --- | --- | --- |
| 100, 30, 10 | inverse transform | 2.99937 | 1.91046 | +7.2e-4 |
| 5000, 2500, 500 | H2PE | 249.98875 | 112.36890 | -1.4e-3 |
| 10000, 1000, 2000 | H2PE | 199.98753 | 143.80349 | -1.5e-3 |
| 100000, 100, 1000 | draw loop | 0.99980 | 0.98646 | -2.6e-3 |

The previously panicking case now matches the theoretical mean and variance.

## Validation

- New unit test `hypergeometric rare-success moderate population falls back
  without overflow` checks the `.draw_loop` method, mean 1.0 ± 0.05, and
  variance 0.989 ± 0.09 at 50k samples.
- The large-population test now asserts the fallback instead of the old
  rejection.
- `zig build test --summary all` passes 940/940 (native `alea-tests`
  921/921).
- `zig build distcheck` passes with the four new variance gates.

The aggregate `validate-all` refresh is tracked as the following milestone.
