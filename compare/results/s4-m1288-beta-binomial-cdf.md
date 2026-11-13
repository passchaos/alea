# S4-M1288 — Beta-binomial PMF, CDF, and quantile

## Goal

Complete the beta-binomial diagnostics surface with the PMF, CDF, and
quantile:

- `betaBinomialPmf(k, trials, α, β)`.
- `betaBinomialCdf(k, trials, α, β)`.
- `betaBinomialQuantile(q, trials, α, β)`.
- Matching `BetaBinomial.pmf` / `.cdf` / `.quantile` methods.

## Implementation

### PMF

`betaBinomialPmf` uses the log-gamma form:

```
P(X=k) = C(n,k) · B(k+α, n−k+β) / B(α, β),
```

computed entirely in log space and exponentiated once. Non-integer `k`,
out-of-support `k`, and invalid parameters follow the 0/NaN conventions.

### CDF

`betaBinomialCdf` uses a stable log-space recurrence:

- `log P₀ = lgamma(n+β) + lgamma(α+β) − lgamma(β) − lgamma(n+α+β)`.
- `log P_{j+1} = log P_j + log(n−j) − log(j+1) + log(j+α) − log(n−j+β−1)`.
- Terms are combined with `logAddExpF64`, so the sum remains stable even when
  individual PMF terms are far below the representable range.

`k < 0 → 0`, `k ≥ n → 1`, and `trials = 0 → 1`.

### Quantile

`betaBinomialQuantile` binary-searches the smallest integer `k ∈ [0, n]` with
`CDF(k) ≥ q`; `q = 0 → 0`, `q = 1 → n`.

## Tests added (2 new, total 835)

1. `BetaBinomial pmf and cdf match the uniform and binomial limits` —
   `α=β=1` uniform PMF `1/(n+1)` and CDF `(k+1)/(n+1)` for every `k`,
   large-`α,β` binomial-limit PMF/CDF for `n=20`, PMF normalization over the
   support, endpoints, and invalid parameters.
2. `BetaBinomial quantile and sampler methods work` — quantile
   coverage/minimality for q = 0.1/0.5/0.9, q=0/q=1 endpoints, and method
   delegation to the free functions.

The recurrence initially omitted the `−1` in the beta-function ratio
denominator; the uniform-limit test caught it before commit.

## Validation

- `zig build test` passes: 835/835 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "BetaBinomial"` passes 5/5.
- `docs/api-reference.md` updated for all 6 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1288 row added.

## Deviations and notes

- The CDF is O(k) per call and the quantile is O(n log n); both are diagnostics
  paths, not hot sampling paths.
- The PMF/CDF take `f64` `k` to match the other discrete CDF helpers and floor
  non-integer counts.

## Next bar

Matrix von Mises-Fisher, Kent distribution, beta-binomial vector sampling,
vector/SIMD copula/Bingham sampling, longer statistical validation runs, or
newly discovered core gaps against local Rust `rand` / `rand_distr` evidence.
