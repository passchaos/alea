# S4-M1322 — Closed-form CDF and quantile helpers

## Goal

Extend the distribution diagnostics surface with closed-form CDF and quantile
helpers for six continuous families that previously had samplers but no
diagnostics: Laplace, Logistic, Cauchy, Rayleigh, Weibull, and Gumbel. Local
Rust `rand_distr` provides none of these CDFs.

## Implementation

New public helpers:

- `laplaceCdf(x, location, scale)` / `laplaceQuantile(p, location, scale)`,
- `logisticCdf` / `logisticQuantile`,
- `cauchyCdf` / `cauchyQuantile`,
- `rayleighCdf` / `rayleighQuantile`,
- `weibullCdf` / `weibullQuantile`,
- `gumbelCdf` / `gumbelQuantile`.

Conventions match the existing diagnostics:

- non-finite location/shape or negative/non-finite scale returns NaN,
- `p` outside `[0, 1]` returns NaN,
- `p = 0` / `p = 1` return the support endpoints (`−∞`/`+∞`, or `0`/`+∞`
  for non-negative supports),
- `scale = 0` is a point mass at the location (or at `0` for Rayleigh and
  Weibull),
- f32 and f64 are supported.

The Logistic and Cauchy CDFs use branch-stable forms
(`exp(−|z|)` and `atan`) so both tails stay finite; Gumbel uses the
`exp(−exp(−z))` double-exponential form.

## Tests added (2 new, total 878)

1. **Round-trips and reference values** — Laplace `F(0)=0.5`, `F(±1)`;
   Logistic `F(1)=1/(1+e⁻¹)`; Cauchy `F(±1)=0.75/0.25`; Rayleigh
   `F(1)=1−e^{−1/2}`; Weibull(1,2) `F(1)=1−e^{−1}`; Gumbel `F(0)=e^{−1}`;
   all quantile round-trips at `p = 0.1, 0.25, 0.5, 0.9` within `1e-12`.
2. **Edge cases and f32** — zero-scale point masses, endpoint infinities,
   invalid parameters/p returning NaN, and f32 reference values.

## Validation

- `zig test src/root.zig --test-filter "closed-form continuous"` passes 2/2.
- `zig build apicheck` and `zig build distcheck` pass.
- `zig build test --summary all` passes 878/878 tests with all documentation
  gates.
- README, `docs/core-guide.md`, and `docs/api-reference.md` updated for all 12
  new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1322 row added.

## Next bar

CDF/quantile coverage for the remaining derived families (Frechet, Pareto,
PowerFunction, Kumaraswamy, Arcsine, Triangular), O(3) matrix Fisher
reflections, further vector compaction, or newly discovered core gaps.
