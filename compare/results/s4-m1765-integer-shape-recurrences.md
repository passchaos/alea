# S4-M1765 Integer-Shape Recurrences for Hoyt and Beta-Family Quantiles

Date: 2026-11-20

## Gap

Several remaining slow rows evaluated a fresh incomplete-gamma or incomplete-beta
special function per series term or per Newton iteration even though the
relevant shape parameter was an integer:

- the Hoyt CDF sums `Σ c_n P(2n+1, ay)` and called `gammaIncompleteP(2n+1, ay)`
  (with lgamma, log, and exp) for every term, so the CDF ran at 4.15M/s and the
  quantile at 0.728M quantiles/s;
- the FisherF quantile routed `(5, 20)` through `betaQuantile(p, 2.5, 10)` and
  the generic continued fraction (1.051M quantiles/s);
- the beta quantile `(2, 3)` and the PERT quantile (shape 4 centered gives
  `Beta(3, 3)`) also used the generic continued fraction (3.59M and 1.71M
  quantiles/s).

## Change

`src/distributions.zig` now:

- advances `P(k, ay)` inside the Hoyt series with the Poisson recurrence
  `P(k+1, y) = P(k, y) - e^-y·y^k/k!` from `P(1, ay) = -expm1(-ay)`, so each
  term costs a few multiplies instead of a full incomplete gamma;
- adds `betaCdfIntegerBWithPdf`, which evaluates `I_x(a, b)` for integer
  `b ∈ [1, 64]` with the recurrence
  `I_x(a, b+1) = I_x(a, b) + x^a(1-x)^b/(b·B(a,b))` from `I_x(a,1) = x^a`.
  The running term also yields the density as `term·b/(x(1-x))`, so the
  quantile Newton needs no logs or lgamma. `x^a` uses a half-integer power
  helper for `a ∈ [1, 64]` and falls back to `pow` for other shapes;
- uses that recurrence in `fisherFCdf`/`fisherFQuantile` when either degree of
  freedom gives an integer second beta parameter in `[1, 64]` (even `d2`
  directly, even `d1` through the `I_x(a,b) = 1 - I_{1-x}(b,a)` symmetry);
- uses it in `betaQuantile` when the beta shape is an integer in `[1, 64]`
  (directly or through the symmetry), which also covers the PERT quantile.
  The fast path requires both shapes `>= 1`; tiny shapes keep the generic
  log-space lower-tail refinement, and f32 keeps the generic path.

The public `betaIncomplete` and `gammaIncompleteP` remain unchanged, so
distribution sampling streams and other CDF callers are unaffected.

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 17179869184 "<filter>"` (4.19M evaluations per row):

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea hoyt cdf` | 4.146M cdf/s | 82.674M cdf/s | 19.9x |
| `alea hoyt quantile` | 0.728M quantiles/s | 4.521M | 6.2x |
| `alea fisher-f cdf` | new row | 352.817M cdf/s | - |
| `alea fisher-f quantile` | 1.051M | 13.596M | 12.9x |
| `alea beta quantile` | 3.588M | 20.097M | 5.6x |
| `alea pert quantile` | 1.712M | 20.399M | 11.9x |

All checksums are unchanged: Hoyt CDF `1643907.474` and quantile
`3624545.774`, FisherF CDF `1520383.233` and quantile `4658079.805`, beta
`1677640.454`, PERT `2097084.279`.

## Validation

- `zig build test --summary all`: 29/29 steps, 994/994 tests, including the
  FisherF known-value/round-trip tests, the tiny-shape beta/gamma median tests,
  and the extreme-scale closed-form CDF tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because every recorded
  checksum is identical.

## Next Bar

Refresh validate-all/long-run evidence and continue with the remaining slow
rows (wrapped skew-normal quantile 0.272M, von Mises 0.967M, skew-normal
1.031M, and the vector-directional samplers).
