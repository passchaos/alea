# S4-M1763 Wrapped Normal Cache and Quantile Newton Correction Fast Paths

Date: 2026-11-20

## Gap

After the S4-M1762 wrapped skew-normal work, the remaining slow diagnostic
quantiles were CDF-limited. Two reusable issues remained:

- `wrappedNormalCdfImpl` recomputed the fixed `-pi` endpoint term for every
  `2*pi` image on every call, and the wrapped normal quantile recomputed both
  CDF and density image sums per Newton iteration.
- The von Mises, Rice, Hoyt, and skew-normal quantiles stopped only on the
  bracket width, so they kept bisecting after the Newton correction was
  already below the x tolerance (the same issue fixed for the wrapped
  skew-normal quantile in S4-M1762).

## Change

`src/distributions.zig` now:

- adds `WrappedNormalCdfCache(T)`, which lazily stores the endpoint image terms
  for one parameter set, skips images where the point and endpoint both
  saturate beyond `|z| >= 9`, and evaluates CDF and density in one image pass;
  `wrappedNormalCdfImpl` uses it, and `wrappedNormalQuantileImpl` reuses one
  cache across iterations with the same `|F(x) - p| <= f'(x) * tol` early exit;
- applies the Newton-correction early exit to the von Mises, Rice, Hoyt, and
  skew-normal quantiles with each function's existing x tolerance
  (`1e-12` absolute for von Mises/skew-normal, `1e-12 * max(1, |x|)` for
  Rice/Hoyt).

All changes are stream-preserving: every recorded quantile checksum is
identical before and after.

## Measurements

Same host, `ReleaseFast -Dcpu=native`, `bench -- 1073741824 "<filter>"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea wrapped normal quantile` | 0.821M quantiles/s | 3.777M quantiles/s | 4.60x |
| `alea wrapped skew-normal quantile` | 0.085M | 0.269M | 3.16x (with S4-M1762) |
| `alea von mises quantile` | 0.791M | 0.979M | 1.24x |
| `alea hoyt quantile` | 0.641M | 0.775M | 1.21x |
| `alea rice quantile` | 2.358M | 2.769M | 1.17x |
| `alea skew-normal quantile` | 0.891M | 1.037M | 1.16x |

Checksums before and after: wrapped normal `400208.032`, wrapped skew-normal
`281729.930`, von Mises `130963.985`, Hoyt `226452.951`, Rice `405771.790`,
skew-normal `147711.284`.

## Validation

- `zig build test --summary all`: 29/29 steps, 994/994 tests, including the
  quantile round-trip, monotonicity, and distribution-quantile tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the outputs are
  bit-identical.

## Next Bar

Refresh validate-all/long-run evidence and continue with the StudentT quantile
(extreme-shape beta inversion) and the vector-directional rows.
