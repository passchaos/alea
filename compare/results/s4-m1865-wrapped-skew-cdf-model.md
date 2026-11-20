# S4-M1865 Reusable Wrapped Skew-Normal CDF Model

Date: 2026-11-20

## Gap

The public `wrappedSkewNormalCdf` rebuilds the 12-point Owen geometry table
and the endpoint image terms on every call. At `(mu, sigma, alpha) =
(0.4, 1.0, 2.0)` that setup is more than half of the ~190 ns row, so a
caller evaluating the CDF at many angles for one parameter set pays it
every time.

## Change

Added `WrappedSkewNormalCdfModel(T)` with `init(mu, sigma, alpha)` and
`cdf(x)`:

- `init` validates the parameters, wraps `mu`, builds the
  `WrappedSkewNormalCdfCache` for `0 < sigma < 10`, and eagerly builds
  both endpoint branches;
- `cdf` handles the `±pi` boundaries, the `sigma = 0` point mass, the
  `sigma >= 10` uniform limit, and NaN, then evaluates the cached image
  sum;
- f32 and f64 are supported; the state is f64 internally.

The table path uses the quantile's 6.5-sigma image threshold, so values
agree with `wrappedSkewNormalCdf` to about 8e-11 (the free function keeps
the tighter 9-sigma threshold and remains the accuracy reference); the
type's doc comment states the tolerance. The API reference records the
three new symbols.

## Measurements

Three runs of the same bench binary (`-- 16777216 "wrapped skew-normal
cdf"`), free and model rows side by side at `(0.4, 1.0, 2.0)`:

| Row | Runs (M cdf/s) |
| --- | --- |
| `alea wrapped skew-normal cdf` (free) | 5.171, 5.188, 5.517 |
| `alea wrapped skew-normal cdf model` | 10.995, 11.219, 11.152 |

The model row is about 2.15x the free row (median 5.19M -> 11.15M), with
the identical checksum `1462.384`.

## Accuracy

A grid over five sigmas (0.2, 0.5, 1, 2, 5), four shapes (-2, -1, 0.5, 2),
and 126 angles measures a worst model-versus-free difference of 8.04e-11
at `sigma = 1`, `alpha = 0.5`, `x = 0.617`. The new test checks the model
against the free CDF within 1e-10 over the same grid, plus the `sigma = 0`
point mass, the `sigma = 12` uniform limit, the exact `±pi` boundaries,
invalid parameters, and NaN.

## Validation

- `zig build test --summary all`: 29/29 steps, 999/999 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.
- `zig build apicheck`: `apicheck ok`.

## Next Bar

The reusable-model family now covers the von Mises CDF (2.5x), the
runtime-shape skew CDF (1.5x, bit-identical), and the wrapped skew CDF
(2.15x); the 1e9 background run remains the next statistical bar.
