# S4-M1287 — Beta-binomial distribution

## Goal

Add the beta-binomial distribution over `0..trials`:

```
X | p ~ Binomial(trials, p),   p ~ Beta(α, β).
```

Beta-binomial is the canonical overdispersed binomial count used for
clustered binary data, beta-binomial regression, and hierarchical models.
`α = β = 1` gives the discrete uniform distribution over `0..trials`; large
`α, β` approach the binomial limit with `p = α/(α+β)`. It is absent from local
Rust `rand` / `rand_distr` core.

## Implementation

### Public API

`BetaBinomial`:

- `init(trials, alpha, beta_param) BetaBinomialError!Self` / `new(...)`.
- `trialsValue`, `alphaValue`, `betaValue`.
- `expectedValue` = `n·α/(α+β)`.
- `varianceValue` = `n·α·β·(α+β+n) / ((α+β)²·(α+β+1))`.
- `minValue` = 0, `maxValue` = `trials`.
- `sample` / `sampleFrom` / `fill` / `fillFrom`.

Free-function family:

- `betaBinomial`, `betaBinomialFrom`, `betaBinomialChecked`,
  `betaBinomialCheckedFrom`.
- `fillBetaBinomial`, `fillBetaBinomialFrom`, `fillBetaBinomialChecked`,
  `fillBetaBinomialCheckedFrom`.

`BetaBinomialError` aliases the distribution `Error` set.

### Sampling

One `Beta(α, β)` draw for `p`, followed by one `binomialFrom(trials, p)` draw.
This is exact and rejection-free at the beta-binomial level, reusing the
existing Beta and binomial samplers and their fast paths.

## Tests added (3 new, total 833)

1. `BetaBinomial constructor and moments` — invalid parameters, `n=10,
   α=β=1` mean/variance (`5`/`10`), support bounds, and accessors.
2. `BetaBinomial sampling matches moments and overdispersion` — 20,000-sample
   uniform-case mean/variance, overdispersed `α=β=0.5, n=20` mean/variance
   (`10`/`52.5`), and the large-`α,β` binomial limit (`10`/`5`).
3. `BetaBinomial free functions and fill work` — free-function sample, fill,
   range checks, and invalid-parameter errors.

## Validation

- `zig build test` passes: 833/833 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "BetaBinomial"` passes 3/3.
- `docs/api-reference.md` updated for all 23 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1287 row added.

## Deviations and notes

- The sampler is intentionally a compound Beta+binomial draw rather than a
  direct PMF inversion; this keeps the implementation exact and reuses the
  verified component samplers.
- CDF/quantile helpers are not included in this milestone; the PMF requires a
  beta-binomial coefficient sum or incomplete-beta identity, which can be a
  follow-up if needed.
- The type is non-generic f64/u64 like `Binomial` and `NegativeBinomial`.

## Next bar

Matrix von Mises-Fisher, Kent distribution, Beta-binomial CDF/quantile and
vector sampling, vector/SIMD copula/Bingham sampling, longer statistical
validation runs, or newly discovered core gaps against local Rust `rand` /
`rand_distr` evidence.
