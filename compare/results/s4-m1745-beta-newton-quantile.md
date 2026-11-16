# S4-M1745 Beta Safeguarded-Newton Quantile

Date: 2026-11-16

## Change

`betaQuantile` used 100 bisection iterations on `betaIncomplete`. Replaced it
with a safeguarded Newton using the beta density:

- stable mean start `alpha/(alpha+beta)` (with a ratio form when the sum
  overflows for huge shapes);
- bracket `[0, 1]`, midpoint fallback when Newton leaves the bracket or the
  density is non-finite, stop on `F(x) == p` or at the existing linear
  resolution;
- the log-space tiny-quantile refinement is preserved when `lo == 0`.

The converged Newton point is returned instead of the stale bracket midpoint;
this was the only correctness issue found during the probe.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"quantile"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea beta quantile` | 0.575 M/s | 3.256 M/s | 5.7x |
| `alea pert quantile` | 0.355 M/s | 1.617 M/s | 4.6x |
| `alea student-t quantile` | 0.194 M/s | 0.750 M/s | 3.9x |
| `alea fisher-f quantile` | 0.206 M/s | 1.040 M/s | 5.0x |
| `alea gamma quantile` | 0.298 M/s | 0.297 M/s | unchanged |
| `alea chi-squared quantile` | 0.191 M/s | 0.192 M/s | unchanged |

All checksums are unchanged (`1608.678`, `2016.950`, `-223.559`, `4462.138`).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- Beta round-trip tests cover `(2,5)`, `(0.5,0.5)`, and `(3,7)` at
  p = 0.05..0.99; the huge-shape `(1e300,1e300)` and tiny-shape `(1e-3,1)`
  tests pass, as do the StudentT, FisherF, and PERT quantile tests.
- Follow-up: S4-M1746 refreshes `validate-all`.
