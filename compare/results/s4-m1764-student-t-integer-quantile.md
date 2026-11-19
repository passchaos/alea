# S4-M1764 Integer-df Student-t Quantile and Gamma Early Exit

Date: 2026-11-20

## Gap

The Student-t quantile was one of the slowest diagnostic rows
(0.778M quantiles/s at a 4.19M-call run). It routed every request through
`betaQuantile(2p, nu/2, 0.5)`; the generic incomplete-beta continued fraction
with the `(2.5, 0.5)` parameter pair costs about 0.87µs per call (a new
`alea beta (2.5,0.5) quantile` diagnostic row measures 1.15M/s), while the
library already had an exact O(nu) recurrence for the small-integer Student-t
CDF.

The gamma quantile also stopped only on the bracket width, so it kept
bisecting after the Newton correction was already below its relative x
tolerance. This mattered most for the chi-squared quantile, which delegates to
the gamma quantile with shape `dof/2 = 2.5`.

## Change

`src/distributions.zig` now:

- adds `studentTQuantileSmallIntegerF64`, a safeguarded Newton on the exact
  `studentTCdfSmallInteger` recurrence with the analytic Student-t density and
  a comptime table of `Γ((ν+1)/2)/(√(νπ)Γ(ν/2))` constants for `ν = 1..64`;
  the start is the Cornish-Fisher expansion for moderate probabilities and the
  `c·ν^((ν-1)/2)·t^-ν` tail asymptotic for `1-q < 1e-4`;
- hooks that path into `studentTQuantileImpl` for f64 integer `ν <= 64`
  (non-integer, larger, and f32 degrees of freedom keep the beta path);
- adds the `|F(x)-p| <= f(x)·tol` Newton-correction exit to the gamma
  quantile, returning directly so the tiny-quantile log-space refinement is
  not entered on an already-converged value;
- adds a permanent `alea beta (2.5,0.5) quantile` diagnostic row so the
  Student-t parameter cost stays visible.

The beta-quantile early-exit variant was measured and rejected: it regressed
the `(2,3)` row from 3.60M to 2.93M quantiles/s with identical output because
the extra correction test never fires before the bracket test for that
parameter pair.

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 17179869184 "<filter>"` (4.19M evaluations per row):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea student-t quantile` | 0.778M quantiles/s | 10.250M quantiles/s | 13.2x |
| `alea chi-squared quantile` | 1.884M | 2.693M | 1.43x |
| `alea gamma quantile` | 4.327M | 4.996M | 1.15x |
| `alea beta quantile` | 3.602M | 3.588M | unchanged (rejected variant reverted) |

All checksums are unchanged: Student-t `-421.768`, chi-squared
`20967375.727`, gamma `25159904.904`, beta `1677640.454`. The known-value and
round-trip Student-t tests pass at their existing 1e-9 tolerances.

## Validation

- `zig build test --summary all`: 29/29 steps, 994/994 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the outputs are
  bit-identical.

## Next Bar

Refresh validate-all/long-run evidence and continue with the remaining slow
quantiles (wrapped skew-normal 0.27M, Hoyt 0.77M, von Mises 0.98M, FisherF
1.05M) and the vector-directional rows.
