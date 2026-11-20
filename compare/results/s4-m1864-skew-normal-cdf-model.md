# S4-M1864 Reusable Skew-Normal CDF Model

Date: 2026-11-20

## Gap

The public `skewNormalCdf` builds the Owen geometry table on every call for
runtime shapes (`0 < |shape| <= 2`): the table build is about 28 ns of the
~68 ns runtime-shape row (S4-M1858), so a caller evaluating the CDF at many
points for one `(location, scale, shape)` pays it every time. Literal
shapes fold at comptime, but real callers with runtime parameters do not.

## Change

Added `SkewNormalCdfModel(T)` with `init(location, scale, shape)` and
`cdf(x)`:

- `init` validates the parameters once and builds the 12-point Owen
  geometry table when `0 < |shape| <= 2`;
- `cdf` mirrors the free function's dispatch exactly (NaN, degenerate
  scale, infinite endpoints, then the cached table or the generic path),
  so values are **bit-identical** to `skewNormalCdf`;
- f32 and f64 are supported; the state is f64 internally.

The API reference records the three new symbols.

## Measurements

Three runs of the same bench binary (`-- 16777216 "skew-normal cdf"`) with
the runtime-shape and model rows side by side:

| Row | Runs (M cdf/s) |
| --- | --- |
| `alea skew-normal cdf runtime` (free) | 15.508, 18.255, 15.382 |
| `alea skew-normal cdf model` | 23.168, 29.015, 22.883 |

The model row is about 1.5x the free runtime row (median 15.5M -> 23.2M),
with the identical checksum `1643.182`, confirming the bit-identical
values.

## Accuracy

The new test asserts `expectEqual` (exact equality) between the model and
`skewNormalCdf` over `shape` in {-6, -2, -1, 0, 0.5, 2, 6} and 129 `x`
points from -8 to 8, plus the degenerate-scale point mass, the f32 path,
and invalid parameters.

## Validation

- `zig build test --summary all`: 29/29 steps, 998/998 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.
- `zig build apicheck`: `apicheck ok`.

## Next Bar

The wrapped skew-normal CDF model is the remaining candidate (~1.5x, with
a documented ~1e-11 difference because its table path uses the quantile's
6.5-sigma threshold); the 1e9 background run remains the next statistical
bar.
