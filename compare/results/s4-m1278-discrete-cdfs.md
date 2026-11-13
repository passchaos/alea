# S4-M1278 — Discrete CDF and quantile helpers

## Goal

Complete the discrete-distribution diagnostics surface with CDF and quantile
helpers for the Binomial, Geometric, NegativeBinomial, and Poisson families:

- `binomialCdf(k, n, p)` / `binomialQuantile(q, n, p)`.
- `geometricCdf(k, p)` / `geometricQuantile(q, p)`.
- `negativeBinomialCdf(k, successes, p)` / `negativeBinomialQuantile(...)`.
- `poissonQuantile(q, λ)` (complementing the S4-M1277 `poissonCdf`).

These helpers reuse the existing incomplete-beta and incomplete-gamma
implementations and give the library CDF/quantile coverage for its discrete
samplers. Rust `rand_distr` provides none of these diagnostics.

## Implementation

### Binomial

- `binomialCdf(k, n, p) = I_{1−p}(n−k, k+1)` for `0 ≤ k < n`, with `k < 0 → 0`
  and `k ≥ n → 1`; `p = 0` and `p = 1` follow the same beta endpoints.
- `binomialQuantile` binary-searches the smallest integer `k ∈ [0, n]` with
  `CDF(k) ≥ q`; `q = 0 → 0`, `q = 1 → n`.

### Geometric

- `geometricCdf(k, p) = 1 − (1−p)^k` for alea's one-based trial-count
  semantics; `k < 1 → 0`, `p = 0 → 0`, `p = 1 → 1`.
- `geometricQuantile(q, p) = ceil(ln(1−q)/ln(1−p))` with a small floating
  tolerance so exact powers of two do not round up; `q = 0 → 1`,
  `p = 0` or `q = 1 → +∞`, `p = 1 → 1`.

### Negative binomial

- `negativeBinomialCdf(k, successes, p) = I_p(successes, k+1)` for the
  failure-count parameterization; `k < 0 → 0`, `p = 0 → 0`, `p = 1 → 1`.
- `negativeBinomialQuantile` doubles an upper bound and binary-searches the
  smallest integer `k` with `CDF(k) ≥ q`.

### Poisson

- `poissonQuantile` doubles an upper bound from `ceil(λ)+1` and binary-searches
  the smallest integer `k` with `poissonCdf(k, λ) ≥ q`; `q = 0` or `λ = 0 → 0`,
  `q = 1 → +∞`.

## Tests added (4 new, total 824)

1. `binomialCdf and binomialQuantile match known values` — n=10/p=0.5 CDF at
   k=5 (`0.623046875`), n=4/p=0.25 CDF at k=1 (`0.73828125`), endpoint and
   degenerate-p behavior, quantile coverage/minimality across three
   probabilities, and f32 support.
2. `geometricCdf and geometricQuantile match known values` — p=0.5 CDF at
   k=1/2/3, quantiles 1/2/3/4, q=0, p=0 infinite quantile, and p=1.
3. `negativeBinomialCdf and negativeBinomialQuantile match known values` —
   s=3/p=0.5 CDF at k=0/1/2 (`0.125`/`0.3125`/`0.5`), negative-k endpoint, and
   quantile coverage/minimality.
4. `poissonQuantile returns the smallest covering count` — λ=2 quantiles for
   q=0.5/0.9/0.95 (`2`/`4`/`5`), λ=0 point mass, and coverage/minimality across
   four probabilities for λ=5.

## Validation

- `zig build test` passes: 824/824 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "Cdf"` and
  `--test-filter "poissonQuantile"` pass.
- `docs/api-reference.md` updated for all 7 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1278 row added.

## Deviations and notes

- Discrete quantiles return the smallest covering integer, matching the usual
  `P(X ≤ k) ≥ q` convention; the return type remains the floating type used by
  the sampler parameters.
- `geometricQuantile` subtracts a `64·ε` tolerance before `ceil` to avoid
  off-by-one errors when the ratio is an exact integer but floating rounding
  pushes it just above.
- `poissonQuantile` and `negativeBinomialQuantile` cap doubling at
  `maxInt(usize)/2` and return `+∞` rather than overflowing.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
