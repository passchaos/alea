# S4-M1867 Wrapped Skew-Normal Quantile Model

Date: 2026-11-20

## Gap

The free `wrappedSkewNormalQuantile` builds the `WrappedSkewNormalCdfCache`
(geometry table and endpoint image terms) on every call: about 100 ns of
the ~435 ns row at `(0.4, 1.0, 2.0)`. A caller solving many probabilities
for one parameter set pays that setup every time. S4-M1865 already gave
the wrapped model an eager cache for `cdf`; the quantile solve was the
missing half.

## Change

- Extracted `wrappedSkewNormalQuantileSolve(cache, p)` from the quantile
  implementation; the free function now builds its cache and calls the
  shared solve, so its behavior is unchanged.
- Added `WrappedSkewNormalCdfModel.quantile(p)`, which handles `p = 0/1`,
  the `sigma = 0` point mass, the `sigma >= 10` uniform limit, and NaN,
  then runs the shared solve against the model's cache.
- The API reference records the new method.

## Measurements

Three runs of the same bench binary (`-- 16777216 "wrapped skew-normal
quantile"`), free and model rows side by side at `(0.4, 1.0, 2.0)`:

| Row | Runs (M quantiles/s) |
| --- | --- |
| `alea wrapped skew-normal quantile` (free) | 2.259, 2.237, 2.329 |
| `alea wrapped skew-normal quantile model` | 2.960, 2.703, 2.830 |

The model row is about 1.25x the free row (median 2.26M -> 2.83M), with
the identical checksum `4282.426`.

## Accuracy

- A 2080-value dump (plain and wrapped skew quantiles over 16 shapes and
  13 probabilities, nine wrapped sigmas) is bit-identical between the
  pre-refactor and post-refactor binaries.
- The model test now asserts `expectEqual` between the model and
  `wrappedSkewNormalQuantile` over five sigmas, four shapes, and 100
  probabilities, plus the degenerate point mass, the uniform limit, and
  the exact `p = 0/1` endpoints.

## Validation

- `zig build test --summary all`: 29/29 steps, 999/999 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.
- `zig build apicheck`: `apicheck ok`.

## Next Bar

The reusable-model family now covers the von Mises CDF (2.5x), the
runtime-shape skew CDF (1.5x), and the wrapped skew CDF (2.15x) and
quantile (1.25x); the 1e9 background run remains the next statistical bar.
