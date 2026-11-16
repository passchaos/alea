# S4-M1758 Wrapped Skew-Normal Circular Distribution

Date: 2026-11-16

## Change

Added the wrapped skew-normal, obtained by wrapping `SN(mu, sigma^2, alpha)`
around the unit circle. The public surface follows the existing circular
distributions:

- `WrappedSkewNormal(T)` with `mu`/`sigma`/`alpha`, `locationValue`,
  `scaleValue`, `shapeValue`, `minValue`, `maxValue`, `cdf`, `quantile`,
  `sample`, `sampleFrom`, `fill`, and `fillFrom`.
- `StandardWrappedSkewNormal` with `mu = 0`, `sigma = 1`, `alpha = 1`.
- Free scalar/vector/checked/fill helpers and `VectorWrappedSkewNormal(T)`.

Sampling draws the skew-normal and wraps it; `sigma = 0` is a point mass at
the wrapped `mu`. The vector sampler uses the fast vector skew-normal path.

The CDF sums the skew-normal CDF over the `2*pi` images and reuses the
S4-M1752 Owen T Gauss-Legendre fast path. The upper-tail branch uses
`Q(1/2, z^2/2)` through `gammaIncompleteQ` plus `2T(z, alpha)` so the tail
near `pi` does not inherit the A&S normal-CDF floor; `alpha = 0` keeps the
direct lower sum so it matches `WrappedNormal` exactly. The quantile is
safeguarded Newton on the wrapped density.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"wrapped skew"`:

| Row | Throughput | Checksum |
| --- | --- | --- |
| `alea wrapped skew-normal` | 401.6 M samples/s | `8023302545600923310` |
| `alea vector wrapped skew-normal f64x4` | 60.8 M vectors/s (243 M lanes/s) | `7027234607582641038` |
| `alea wrapped skew-normal cdf` | 0.731 M cdf/s | `1462.384` |
| `alea wrapped skew-normal quantile` | 0.091 M quantiles/s | `4282.426` |

## Validation

- 9 new tests: constructor validation, `alpha = 0` matches `WrappedNormal`,
  CDF/quantile round-trips for `sigma = 0.5/1/3` and `alpha = -2/-1/0.5/2`,
  `sigma = 0` point mass and large-`sigma` uniform limit, bounded/skewed
  sampling, SIMD lanes, checked helpers, and standard parameters.
- New scalar and vector long binned gates in `tools/distcheck.zig`.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 995/995
  tests (native `alea-tests` 972/972).
- `docs/api-reference.md` and `README.md` list the new surface.
- Follow-up: S4-M1759 refreshes `validate-all`; S4-M1760 runs the 1e7 long
  gates with the new binned gates.
