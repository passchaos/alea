# S4-M1731 Wrapped Normal Circular Distribution

Date: 2026-11-16

## Change

Added the wrapped normal distribution, the maximum-entropy circular law for a
fixed mean resultant length and the smooth-tail counterpart to Wrapped Cauchy.
The public surface follows the existing circular-distribution pattern:

- `WrappedNormal(T)` with `mu` (mean direction) and `sigma` (standard deviation
  of the underlying normal, `sigma >= 0`), plus `new`, `locationValue`,
  `scaleValue`, `concentrationValue` (`rho = exp(-sigma²/2)`),
  `expectedValue`, `varianceValue` (`1 - rho`), `medianValue`, `modeValue`,
  `minValue`, `maxValue`, `cdf`, `quantile`, `sample`, `sampleFrom`, `fill`,
  and `fillFrom`.
- `StandardWrappedNormal` with `mu = 0`, `sigma = 1`, and
  `rho = exp(-1/2)`.
- Free scalar helpers `wrappedNormal`, `wrappedNormalFrom`,
  `wrappedNormalChecked`, `wrappedNormalCheckedFrom`, `fillWrappedNormal*`,
  `wrappedNormalCdf`, and `wrappedNormalQuantile`.
- Vector helpers `vectorWrappedNormal*`, `fillVectorWrappedNormal*`, and
  `VectorWrappedNormal(T)`.

## Algorithm

Sampling draws one standard normal and wraps `mu + sigma * z`:

- Scalar samples use `Rng.standardNormalFastFrom` and a modulo wrap that is
  safe for large `sigma`.
- Vector samples use `Rng.vectorStandardNormalFrom` (the f64x4 path uses the
  SIMD ziggurat). When every lane already lands in `(-π, π]`, the lanes are
  returned unchanged (with `-0.0` normalized like the branchless wrap); the
  common case therefore avoids the wrap arithmetic. Out-of-range lanes use the
  existing two-pass `wrapAngleGeneric` when all raw values are within `3π`,
  otherwise the modulo wrap.
- `sigma = 0` is a point mass at the wrapped `mu` and consumes no randomness;
  the all-zero vector case also consumes none.

The CDF on `(-π, π]` sums the `2π` images of the normal CDF:
`Σ_k [Φ((x - mu + 2πk)/σ) - Φ((-π - mu + 2πk)/σ)]`, with `k` covering six
standard deviations on either side. For `sigma >= 10` the wrap error is below
`1e-21` and the uniform limit `(x + π)/(2π)` is used. The quantile uses
bisection on the CDF (70 iterations for f64, 40 for f32) because no closed form
exists.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"wrapped normal"`:

| Row | Throughput | Checksum |
| --- | --- | --- |
| `alea wrapped normal` | 665-676 M samples/s | `2363938913262378931` |
| `alea vector wrapped normal f64x4` | 93-99 M vectors/s (372-398 M lanes/s) | `215130825570594127` |

The vector row is below the `666.8 M lanes/s` raw f64x4 normal direct row
because it adds the circular wrap; the in-range fast path keeps most of the
normal throughput.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 984/984
  tests (native `alea-tests` 961/961, including 10 new Wrapped Normal tests).
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000`:
  `distlongcheck ok (10000000 samples)` with new scalar and vector wrapped
  normal binned gates.
- `zig build roadmapcheck doccheck apicheck readmecheck --summary all`:
  26/26 steps and 19/19 tests.
- `docs/api-reference.md` lists every new public symbol; `README.md` lists the
  new distribution.

## Rust Comparison

Local `rand_distr` 0.6.0 has no wrapped normal distribution. Alea now covers
Von Mises, Wrapped Cauchy, wrapped normal, von Mises-Fisher, Watson, Kent, and
Bingham, extending circular/directional coverage beyond local Rust.

## Changed Files

- `src/distributions.zig`: distribution, CDF/quantile, sampling, vector helpers,
  and tests.
- `docs/api-reference.md`, `README.md`: public surface.
- `tools/distcheck.zig`: scalar/vector long binned gates.
- `bench/throughput.zig`: scalar and f64x4 rows.
- `compare/results/reproducibility-matrix.md`: stream shape.
