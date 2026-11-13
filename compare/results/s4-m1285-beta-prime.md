# S4-M1285 — Beta prime (inverted beta / gamma-gamma) distribution

## Goal

Add the Beta prime distribution on `(0, ∞)`:

```
f(x) ∝ x^{α−1} (1+x)^{−(α+β)} / B(α, β).
```

Beta prime is the ratio of two independent Gamma variates (`G₁/G₂` with
`G₁ ~ Gamma(α,1)`, `G₂ ~ Gamma(β,1)`), the conjugate-style prior for odds and
variance ratios, and the continuous extension of the Beta distribution to the
positive half-line. `BetaPrime(1,1)` is exactly `F(2,2)`. It is absent from
local Rust `rand` / `rand_distr` core.

## Implementation

### Public API

`BetaPrime(T)`:

- `init(alpha, beta_param) BetaPrimeError!Self` / `new(...)`
- `alphaValue`, `betaValue`
- `expectedValue() ?T` — `α/(β−1)` for `β > 1`, null otherwise.
- `varianceValue() ?T` — `α(α+β−1)/((β−2)(β−1)²)` for `β > 2`, null otherwise.
- `modeValue()` — `(α−1)/(β+1)` for `α > 1`, otherwise 0.
- `medianValue()` — `m/(1−m)` with `m = betaQuantile(0.5, α, β)`.
- `minValue()` = 0, `maxValue()` = null.
- `cdf(x)` — `I_{x/(1+x)}(α, β)`.
- `quantile(p)` — `y/(1−y)` with `y = betaQuantile(p, α, β)`.
- `sample` / `sampleFrom` / `fill` / `fillFrom`.

Free-function family:

- `betaPrime`, `betaPrimeFrom`, `betaPrimeChecked`, `betaPrimeCheckedFrom`.
- `fillBetaPrime`, `fillBetaPrimeFrom`, `fillBetaPrimeChecked`,
  `fillBetaPrimeCheckedFrom`.

`BetaPrimeError` aliases the distribution `Error` set.

### Sampling

`B ~ Beta(α, β)`, then `X = B/(1−B)`. This is exact and rejection-free and
reuses the existing Beta sampler, including its Cheng/edge fast paths.

## Tests added (3 new, total 829)

1. `BetaPrime constructor, moments, and degeneracies` — invalid parameters,
   `BetaPrime(3,5)` mean/variance/mode (`0.75`, `0.4375`, `1/3`), infinite
   moments for `β ≤ 1`, `BetaPrime(2,2)` median = 1, and support bounds.
2. `BetaPrime sampling and CDF match the Beta transform` — 20,000-sample mean
   and variance, positivity, `BetaPrime(1,1)` CDF `x/(1+x)` cross-checked
   against `fisherFCdf(x,2,2)`, quantile round-trips, and endpoints.
3. `BetaPrime free functions, fill, and f32 support` — free-function sample,
   fill, invalid-parameter errors, and f32 sampling.

## Validation

- `zig build test` passes: 829/829 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "BetaPrime"` passes 3/3.
- `docs/api-reference.md` updated for all 26 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1285 row added.

## Deviations and notes

- `expectedValue` and `varianceValue` return `?T` so infinite moments are
  explicit rather than encoded as infinity, matching `FisherF`/Wishart style.
- `cdf` uses `x/(1+x)`; values near the positive tail approach 1 without
  overflow for realistic `x`.
- Vector/SIMD sampling is not included in this milestone; the scalar Beta
  sampler and fill APIs are the initial surface.

## Next bar

Matrix von Mises-Fisher, Kent distribution, BetaPrime vector/SIMD sampling,
vector/SIMD copula/Bingham sampling, longer statistical validation runs, or
newly discovered core gaps against local Rust `rand` / `rand_distr` evidence.
