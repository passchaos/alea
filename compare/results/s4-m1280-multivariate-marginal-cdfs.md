# S4-M1280 — Dirichlet and Multinomial marginal CDF/quantile methods

## Goal

Extend the sampler diagnostics to the multivariate families:

- `Dirichlet(T).marginalCdf(index, x)` / `Dirichlet(T).marginalQuantile(index, p)`.
- `Multinomial.marginalCdf(index, k)` / `Multinomial.marginalQuantile(index, q)`.

The Dirichlet marginal of component `i` is
`Beta(α_i, α_0 − α_i)`; the Multinomial marginal of category `i` is
`Binomial(trials, p_i / Σp)`. These methods give credible-interval and
category-count diagnostics without allocating or re-deriving parameters.

## Implementation

### Dirichlet

- `marginalCdf`/`marginalQuantile` validate `index` through `alphaAt`, then
  delegate to `betaCdf`/`betaQuantile` with `(α_i, α_0 − α_i)`.
- A single-infinite-alpha Dirichlet is a vertex point mass: the vertex
  component returns `x < 1 → 0` / `x ≥ 1 → 1` and quantile 1; other components
  return `x < 0 → 0` / `x ≥ 0 → 1` and quantile 0.

### Multinomial

- `marginalCdf`/`marginalQuantile` validate `index` through
  `normalizedProbabilityAt`, then delegate to
  `binomialCdf`/`binomialQuantile` with the normalized category probability.
- Constant-category multinomials (one positive probability) therefore return
  the corresponding binomial point-mass CDF/quantile behavior.

## Tests added (1 new, total 826)

`Dirichlet and Multinomial marginal CDF/quantile methods work` — Beta marginal
CDF equality for `α = [2,3,5]`, continuous quantile round-trip, invalid index;
vertex point-mass behavior for `α = [∞,3,5]`; Binomial marginal CDF equality
for normalized `[1,3]`, discrete quantile coverage/minimality, invalid index;
and constant-category `[0,1,0]` point-mass behavior.

## Validation

- `zig build test` passes: 826/826 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- `docs/api-reference.md` updated for all 4 new public methods.
- `compare/results/core-rand-coverage.md` S4-M1280 row added.

## Deviations and notes

- The marginal methods operate on the original probability vector (normalizing
  on the fly for Multinomial) rather than requiring a normalized copy.
- Discrete marginal quantiles follow the same smallest-covering-integer
  convention as the scalar helpers, so tests assert coverage/minimality rather
  than exact CDF equality at the quantile.
- No new special-function logic was added; this milestone is API ergonomics
  over the verified Beta/Binomial helpers.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
