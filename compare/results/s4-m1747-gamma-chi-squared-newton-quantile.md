# S4-M1747 Gamma and Chi-Squared Newton Quantile

Date: 2026-11-16

## Change

`gammaQuantile` used 100 bisection iterations on `gammaCdf`, and
`chiSquaredQuantile` delegates to gamma. Replaced the main branch with a
safeguarded Newton iteration:

- Wilson-Hilferty start for `shape >= 0.3`, mean start otherwise;
- density `x^(k−1)·e^(−x/θ)/(Γ(k)·θ^k)` evaluated in log form;
- bracket `[0, hi]`, midpoint fallback, stop on `F(x) == p` or at the
  existing linear resolution;
- preserved the upper-tail `Q` bisection for `1-p < 1e-7` and the log-space
  tiny-quantile refinement when `lo == 0`;
- returns the converged Newton point instead of the bracket midpoint.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"quantile"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea gamma quantile` | 0.298 M/s | 3.890 M/s | 13.1x |
| `alea chi-squared quantile` | 0.191 M/s | 1.821 M/s | 9.5x |

Checksums are unchanged (`24090.708`, `20099.358`). The beta/PERT/StudentT/
FisherF rows are unchanged within noise.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- Gamma tests cover `(2.5, 1.5)` at p = 0.05..0.99, tiny shapes `1e-3` and
  `1e-6`, the `1e6`-shape lower tail, and the chi-squared delegation; all
  pass.
- Follow-up: S4-M1748 refreshes `validate-all`.
