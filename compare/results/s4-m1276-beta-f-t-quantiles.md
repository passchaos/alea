# S4-M1276 — Beta/F/Student-t CDF and quantile helpers

## Goal

Complete the distribution diagnostics surface with CDF/quantile helpers built
on the regularized incomplete beta added in S4-M1269:

- `betaCdf(x, α, β)` — Beta CDF alias for `I_x(α, β)`.
- `betaQuantile(p, α, β)` — inverse regularized incomplete beta.
- `fisherFCdf(x, d1, d2)` — Fisher F CDF.
- `fisherFQuantile(p, d1, d2)` — inverse Fisher F CDF.
- `studentTQuantile(p, ν)` — inverse Student-t CDF.

These helpers make t-copula marginal transforms and general distribution
quantile workflows possible without adding a companion statistics package.
Rust `rand_distr` does not provide CDFs or quantiles for these families.

## Implementation

### Beta

- `betaCdf` forwards to `betaIncomplete`, preserving the continued-fraction
  implementation and the `I_x(a,b) = 1 − I_{1−x}(b,a)` symmetry.
- `betaQuantile` uses deterministic bisection on `[0, 1]` with 100 iterations
  and a `64·ε` width stopping rule; `p = 0 → 0`, `p = 1 → 1`, invalid
  parameters return NaN.

### Fisher F

- `fisherFCdf(x, d1, d2)` uses the numerically stable
  `y = d1 / (d1 + d2/x)` form to avoid overflow for large `x`, then evaluates
  `I_y(d1/2, d2/2)`.
- `fisherFQuantile` doubles an upper bound from 1 until the CDF reaches `p`,
  then bisects for 100 iterations; `p = 0 → 0`, `p = 1 → +∞`.

### Student-t

- `studentTQuantile` uses the incomplete-beta relation for `p < 0.5`:
  `x = betaQuantile(2p, ν/2, ½)`, `t = −√(ν(1−x)/x)`; `p > 0.5` uses
  symmetry, `p = 0.5` returns 0, and `ν > 1e6` delegates to `probit`.
- The recursive call and beta arguments are explicitly cast to the common
  type to avoid `comptime_float` instantiation when callers pass
  comptime-known f32 values.

## Tests added (3 new, total 816)

1. `betaCdf and betaQuantile round-trip` — Beta(1,1), Beta(2,1), Beta(2,2)
   closed forms; round-trip `betaCdf(betaQuantile(p)) ≈ p` across five `p`
   values and three parameter pairs; endpoint and invalid-parameter behavior.
2. `fisherFCdf and fisherFQuantile match known values` — F(1,1) and F(2,2) at
   x=1 equal 0.5; F(5,10) at x=1 matches the reference
   `0.5348805734622006`; negative/infinite endpoints; round-trip across
   p = 0.1/0.5/0.9; invalid parameters.
3. `studentTQuantile matches known values and symmetry` — Cauchy (ν=1)
   ±1 quantiles, ν=2 `−0.8164965809277265`, ν=10 `0.6998120613124303`, ν=5
   `1.4758840488244789`; round-trip against `studentTCdf` across six
   probabilities; `ν=1e7` against `probit`; f32 support.

## Validation

- `zig build test` passes: 816/816 tests; `apicheck`, `readmecheck`,
  `toolingcheck`, `roadmapcheck`, and `examplecheck` all green.
- Focused `zig test src/root.zig --test-filter "Quantile"` passes 3/3.
- `docs/api-reference.md` updated for all 5 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1276 row added.

## Deviations and notes

- Quantiles use deterministic bisection rather than Newton iteration. The
  helpers are diagnostic/ergonomic paths, not hot sampling paths, and bisection
  is robust across extreme parameters.
- `fisherFQuantile` can return `+∞` if the doubling bound overflows; this is
  the correct limit for extreme upper-tail probabilities.
- The Student-t quantile inherits the `ν > 1e6` normal approximation used by
  `studentTCdf`, so its error is bounded by the O(1/ν) normal limit.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
