# S4-M1615 Generalized Extreme Value Benchmark Rows and Scalar exp−1 Sampling

Date: 2026-11-15

## New Rows

The Generalized Extreme Value family had no benchmark rows. Added:

- `alea generalized extreme value` (`GeneralizedExtremeValue(f64).new(1, 2, 0.3)`,
  `bytes / 128`): 67.7 M samples/s with the original `expm1` scalar path;
- `alea vector generalized extreme value f64x4`
  (`VectorGeneralizedExtremeValue(V4).new(1, 2, 0.3)`, `bytes / 32`):
  15.5 M vectors/s (62 M samples/s).

The row sits between `alea frechet` (77.7 M, one log plus one exp) and
`alea gumbel` (181.0 M, one log), so the second transcendental dominates the
GEV cost as expected.

## Scalar exp−1 Adoption

`generalizedExtremeValuePointFrom` used `std.math.expm1(-xi * @log(e))`. Zig's
`expm1` is the pure-Zig musl port, while `@exp` lowers to the faster system
`exp` on this host. Replaced the scalar transform with the GPD-style
`(@exp(-xi * @log(e)) - 1)` form. The quantile keeps `expm1` because it is an
accuracy path, not a throughput path.

| Row | `expm1` scalar | `exp−1` scalar |
| --- | --- | --- |
| `alea generalized extreme value` | 67.7 M samples/s | 74.2-78.5 M samples/s |
| `alea vector generalized extreme value f64x4` | 15.5 M vectors/s | 15.2-15.4 M vectors/s |

The scalar row gains 10-16%; the vector path is unchanged because it keeps
`expm1`. A same-period probe that also switched the per-lane vector transform
to `@exp(...) - 1` measured 14.3-14.9 M vectors/s, so the inlined pure-Zig
`expm1` stays there (it pipelines better than per-lane system `exp` calls).

Accuracy of the swapped scalar form against `expm1` for `μ=1`, `σ=2`:

| `ξ` | max `|Δx|`, `E ∈ [1e-3, 20]` | max relative `Δx` |
| --- | --- | --- |
| `0.3` | `3.6e-15` | `3.1e-13` |
| `-0.3` | `1.8e-15` | `2.7e-14` |
| `±0.01` | `2.3e-14` | `7.1e-13` / `1.6e-12` |

`E ∈ [1e-3, 20]` covers more than 99.9999% of the `Exp(1)` mass; the relative
differences occur at `E ≈ e`, where the deviation from `μ` is tiny and the
absolute difference stays at the ulp level of `x`. The recorded benchmark
checksums are unchanged at the printed precision (`393793.141`,
`6259721.691`).

## Validation

- `zig build test -Dtest-filter=GeneralizedExtremeValue --summary all`: 6/6
  GEV tests pass.
- `zig build test distcheck --summary all`: 971/971 (native 950/950).
- `zig build distcheck -Doptimize=ReleaseFast -- --long 10000000`:
  `distlongcheck ok (10000000 samples)`, including the GEV mean/`cdf(3.0)`
  gate and the GEV binned chi-square gate.
- `zig build distcheck -Doptimize=ReleaseFast -- --long 1000000000`:
  `distlongcheck ok (1000000000 samples)` in about 27 minutes with the GEV
  mean/`cdf(3.0)` and binned chi-square gates passing; the non-GEV values
  reproduce S4-M1608/S4-M1602 (`binomial(4)=0.237505`, `gamma(3)=0.450579`,
  normal tail `0.002698`, student-t tail `0.030104`, Gaussian copula
  `0.001875`, skew-normal `0.250011`), confirming the change is confined to
  the GEV sampler.

## Changed Files

- `bench/throughput.zig`: the two GEV rows and their bench functions.
- `src/distributions.zig`: scalar GEV sampling uses `exp(−ξ·ln E) − 1`; the
  vector path keeps `expm1`; doc comments record both.
- `docs/core-guide.md`: records the scalar/vector sampling forms.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the scalar stream
  change.
