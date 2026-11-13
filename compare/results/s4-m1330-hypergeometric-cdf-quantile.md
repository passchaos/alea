# S4-M1330 — Hypergeometric CDF and quantile helpers

## Goal

Close the last missing discrete diagnostics family by adding CDF and quantile
support for the hypergeometric distribution:

- `hypergeometricCdf(k, population, successes, draws)`.
- `hypergeometricQuantile(q, population, successes, draws)`.
- `Hypergeometric.cdf(k)` / `Hypergeometric.quantile(q)` sampler methods.
- `hypergeometricExactSdLimit` documents the exact/approximate regime switch.

Rust `rand_distr` exposes hypergeometric sampling but no CDF or quantile
diagnostics, so this extends the local comparison surface rather than porting
an existing shape.

## Implementation

### Exact tail recurrence

The PMF ratio is

`P(j−1)/P(j) = j·(N−K−n+j) / ((K−j+1)·(n−j+1))`

with the mirrored upward recurrence for `P(j+1)/P(j)`. The CDF starts at `k`
(lower tail) or `k+1` (upper tail, returning `1 − sum`), picks the side using
the mean, and stops once the geometric bound on the remaining tail
`term·ratio/(1−ratio)` falls below `64·ε` of the accumulated sum. Cost is
`O(σ·√ln(1/ε))` instead of `O(support width)`, and terms are monotone on the
chosen side so the bound is safe. The summation terminates at the support
bounds even when the start PMF underflows, returning the correct 0/1 limit.

### Stable log-PMF

- For populations up to 1e9, `log C(a,b)` uses log-gamma differences.
- For populations above 1e9 with a small category (`min(K,n) ≤ 20000`), the
  log-PMF uses the short falling-factorial product
  `C(K,j)·(n)_j·(N−n)_{K−j}/(N)_K` (or the mirrored form with `n`), avoiding
  the catastrophic cancellation of three large log-gamma terms.
- Populations above 2^53 are rejected with NaN because integer parameters are
  no longer exactly representable in f64.

### Large-σ fallback

When the exact standard deviation exceeds `hypergeometricExactSdLimit`
(16384), both helpers switch to the normal approximation with continuity
correction: `cdf(k) ≈ Φ((⌊k⌋ + 0.5 − μ)/σ)`. The approximation error is
`O(1/σ)` near the mode and grows in the far tails; the quantile bisects on the
same approximate CDF so the pair stays consistent.

### Quantile

`hypergeometricQuantile` returns the smallest integer `k` with
`cdf(k) ≥ q`, using deterministic bisection over the integer support and the
usual `q = 0 → min`, `q = 1 → max` conventions.

## Tests added (2 new, total 886)

1. `hypergeometricCdf and hypergeometricQuantile match known values` —
   exact rational CDFs for `N=10, K=6, n=4` and `n=8` (including a nonzero
   support minimum), the `K ↔ n` symmetry, an independent multiplicative
   binomial reference at `N=100, K=40, n=30` below and above the mean,
   smallest-covering quantiles, endpoint/invalid behavior, and f32 support.
2. `hypergeometricCdf large-population paths` — the `N=1e10` balanced case
   exercises the normal fallback (`cdf(μ) ≈ 0.5`, `cdf(μ+σ) ≈ Φ(1)`, median
   quantile), and `N=1e12, K=3` exercises the product-form log-PMF against the
   closed form `(1 − 3/N)^n = 0.995³`.

## Validation

- `zig build test` passes: 886/886 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- `zig build distcheck` passes, including the new hypergeometric quantile
  round-trip and the empirical-frequency gate
  (`Hypergeometric(100, 30, 10).cdf(2)` within `±0.02` of 20,000 samples).
- `zig build run-distribution-diagnostics` prints
  `Hypergeometric(N=100,K=30,n=10): cdf(2)=0.372857, quantile(0.9)=5.0`,
  matching exact integer-combinatorics values (`0.37285659…`, `5`).
- `docs/api-reference.md`, `README.md`, and `docs/core-guide.md` list the new
  symbols, the sampler methods, and the exact/approximate policy.

## Deviations and notes

- The large-σ normal fallback is documented rather than hidden; exact
  summation remains available up to `σ = 16384`, which bounds a single CDF
  evaluation to roughly one million recurrence steps.
- For populations between 1e9 and 2^53 where every category is large, the
  log-gamma path is still used and can lose a few digits to cancellation;
  the documented exactness range is `population ≤ 1e9`. The product path
  covers the practical large-population cases with at least one small
  category.
- The quantile is a diagnostics/ergonomics path, not a hot sampling path.

## Next bar

Further vector compaction/squeeze optimizations, broader platform runners, or
newly discovered core gaps against local Rust `rand` / `rand_distr` evidence.
