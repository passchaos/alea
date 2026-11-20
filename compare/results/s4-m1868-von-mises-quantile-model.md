# S4-M1868 Von Mises Quantile Model

Date: 2026-11-20

## Gap

The free `vonMisesQuantile` builds the `VonMisesCdfCache` (Bessel-ratio and
Fourier tables) on every call: about 40 ns of the ~300 ns row at
`(mu, kappa) = (0.5, 5)`. A caller solving many probabilities for one
parameter set pays that setup every time. S4-M1863 already gave the von
Mises model an eager cache for `cdf`; the quantile solve was the missing
half.

## Change

- Extracted `vonMisesQuantileSolve(T, cache, p, mu, kappa)` from the
  quantile implementation; the free function now builds its cache and
  calls the shared solve, so its behavior is unchanged.
- Added `VonMisesCdfModel.quantile(p)`, which handles the `p = 0/1`
  endpoints, the `kappa = 0` uniform case, and invalid input, then runs
  the shared solve against the model's cache.
- The API reference records the new method.

## Measurements

Three runs of the same bench binary (`-- 16777216 "von mises quantile"`),
free and model rows side by side at `(0.5, 5)`:

| Row | Runs (M quantiles/s) |
| --- | --- |
| `alea von mises quantile` (free) | 3.081, 3.432, 3.325 |
| `alea von mises quantile model` | 3.488, 3.834, 3.799 |

The model row is about 1.14x the free row (median 3.33M -> 3.80M), with
the identical checksum `1966.365`. The gain is smaller than the wrapped
model's because the von Mises table build is only about 40 ns after the
S4-M1848/S4-M1851 recurrence work.

## Accuracy

- A 15,984-value dump (eight kappas including `0`, `1e4`, and `1e5`, two
  locations, 999 probabilities) is bit-identical between the pre-refactor
  and post-refactor binaries.
- The model test asserts `expectEqual` between the model and
  `vonMisesQuantile` for seven kappas and 100 probabilities, plus the f32
  path within 1e-5.

## Validation

- `zig build test --summary all`: 29/29 steps, 999/999 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.
- `zig build apicheck`: `apicheck ok`.

## Next Bar

The reusable-model family now covers the von Mises CDF (2.5x) and
quantile (1.14x), the runtime-shape skew CDF (1.5x), and the wrapped skew
CDF (2.15x) and quantile (1.25x); the 1e9 background run remains the next
statistical bar.
