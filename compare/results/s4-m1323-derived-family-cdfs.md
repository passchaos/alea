# S4-M1323 — Derived-family CDF and quantile helpers

## Goal

Complete the continuous diagnostics surface with closed-form CDF and quantile
helpers for the remaining derived families: Frechet, Pareto, PowerFunction,
Kumaraswamy, Arcsine, and Triangular.

## Implementation

New public helpers:

- `frechetCdf(x, location, scale, shape)` / `frechetQuantile`,
- `paretoCdf(x, scale, shape)` / `paretoQuantile`,
- `powerFunctionCdf(x, min, max, shape)` / `powerFunctionQuantile`,
- `kumaraswamyCdf(x, alpha, beta)` / `kumaraswamyQuantile`,
- `arcsineCdf(x, min, max)` / `arcsineQuantile`,
- `triangularCdf(x, min, mode, max)` / `triangularQuantile`.

Conventions match the existing diagnostics:

- non-finite/invalid parameters return NaN,
- `p` outside `[0, 1]` returns NaN,
- `p = 0` / `p = 1` return the support endpoints,
- collapsed supports are point masses (Frechet/Pareto zero scale, equal
  min/max for PowerFunction/Arcsine/Triangular),
- Triangular handles `mode == min` and `mode == max` without dividing by zero,
- f32 and f64 are supported.

The Kumaraswamy parameter is named `beta_param` internally to avoid shadowing
the `beta` sampler function.

## Tests added (2 new, total 880)

1. **Round-trips and reference values** — Frechet(0,1,2) `F(1)=e⁻¹`,
   Pareto(1,2) `F(2)=0.75`, PowerFunction(0,1,2) `F(0.5)=0.25`,
   Kumaraswamy(2,3) `F(0.5)=0.578125`, Arcsine(0,1) `F(0.5)=0.5` and
   `F(0.25)=1/3`, Triangular(0,0.5,1) `F(0.25)=0.125`, `F(0.5)=0.5`,
   `F(0.75)=0.875`; quantile round-trips at `p = 0.1, 0.25, 0.5, 0.9` within
   `1e-12`, including boundary-mode triangular cases.
2. **Edge cases and f32** — collapsed supports, endpoint values, invalid
   parameters/p returning NaN, and f32 reference values.

## Validation

- `zig test src/root.zig --test-filter "derived-family CDF"` passes 2/2.
- `zig build apicheck` and `zig build distcheck` pass.
- `zig build test --summary all` passes 880/880 tests with all documentation
  gates.
- README, `docs/core-guide.md`, and `docs/api-reference.md` updated for all 12
  new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1323 row added.

## Next bar

O(3) matrix Fisher reflections, further vector compaction/squeeze
optimizations, broader platform runners, or newly discovered core gaps.
