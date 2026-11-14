# S4-M1546 Truncated-Normal and Uniform CDF/Quantile

Date: 2026-11-15

## Feature Gap

`TruncatedNormal` and `Uniform(T)` both had sampling, moments, and support
accessors but no public CDF/quantile. Uniform is a core distribution and
truncated normal is the standard constrained-normal sampler; both have exact
formulas, so this was a diagnostics surface gap.

## Change

- `TruncatedNormal(T).cdf` / `.quantile` and free
  `truncatedNormalCdf` / `truncatedNormalQuantile`.
  - CDF: `(Φ(z) − Φ(α)) / Z` on the window, with `0`/`1` outside and the
    `σ = 0` point mass at the mean.
  - Quantile: `μ + σ·Φ⁻¹(Φ(α) + p·Z)`, clamped to the window, with
    `p = 0 → lower`, `p = 1 → upper`, and NaN for invalid `p` or parameters.
- `Uniform(T).cdf` / `.quantile` for both continuous and integer grids,
  half-open and inclusive.
  - Continuous: clamped linear interpolation.
  - Integer: `(⌊x⌋ − low + 1)/count` with `count = high − low + (inclusive ? 1 : 0)`,
    and the quantile returns `low + ⌈p·count⌉ − 1` clamped to the grid.
  - Results are real-valued (`f64`), matching the discrete distribution
    convention (`Binomial.cdf` etc.).

## Validation

- `TruncatedNormal CDF and quantile match the truncated-normal formulas`
  checks the unbounded normal reduction, the one-sided `[0, ∞)` `2Φ(x) − 1`
  form, the symmetric `[-1, 1]` median and round-trips, the degenerate point
  mass, free-function parity, invalid-parameter NaN, and f32.
- `Uniform CDF and quantile match the uniform grid` checks continuous
  half-open/inclusive cases, integer half-open `[0, 10)`, integer inclusive
  `[1, 6]`, quantile edges, and f32.
- `distcheck` adds truncated-normal and uniform quantile round-trips to the
  continuous diagnostics block.
- `zig build test --summary all` passes 952/952 (native `alea-tests`
  933/933); `zig build distcheck` and `zig build doccheck` (including
  `apicheck` for the six new symbols) pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
