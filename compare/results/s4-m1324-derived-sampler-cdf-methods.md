# S4-M1324 — CDF/quantile methods on derived sampler types

## Goal

Expose the closed-form diagnostics through the reusable sampler types, matching
the existing `cdf(x)` / `quantile(p)` methods on the core continuous and
discrete samplers.

## Implementation

Added `cdf(x)` and `quantile(p)` methods to:

- `Laplace(T)`, `Logistic(T)`, `Cauchy(T)`,
- `Rayleigh(T)`, `Weibull(T)`, `Gumbel(T)`, `Frechet(T)`, `Pareto(T)`,
- `PowerFunction(T)`, `Kumaraswamy(T)`,
- `Arcsine(T)`, `Triangular(T)`.

The methods delegate to the corresponding free helpers. Degenerate
parameterizations are handled explicitly:

- `PowerFunction` with infinite shape (`.point_max`) is a point mass at
  `min + range`;
- `Kumaraswamy` with infinite alpha (`.point_one`) is a point mass at 1, and
  with infinite beta (`.point_zero`) is a point mass at 0.

## Tests added (1 new, total 881)

`derived sampler cdf and quantile methods delegate to the free helpers`
compares every method against its free helper at `x = 0.7`, `p = 0.6`, and
covers the `PowerFunction`/`Kumaraswamy` point-mass branches.

## Validation

- `zig test src/root.zig --test-filter "derived sampler cdf"` passes 1/1.
- `zig build apicheck` and `zig build distcheck` pass.
- `zig build test --summary all` passes 881/881 tests with all documentation
  gates.
- README, `docs/core-guide.md`, and `docs/api-reference.md` updated for all 24
  new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1324 row added.

## Next bar

O(3) matrix Fisher reflections, further vector compaction/squeeze
optimizations, broader platform runners, or newly discovered core gaps.
