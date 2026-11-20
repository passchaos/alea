# S4-M1863 Reusable Von Mises CDF Model

Date: 2026-11-20

## Gap

The public `vonMisesCdf` rebuilds the Fourier-Bessel ratio table on every
call: for `kappa = 5` that is about 100 ns of the ~127 ns row, so a caller
evaluating the CDF at many angles for one `(mu, kappa)` pays the setup
every time. The quantile already builds a `VonMisesCdfCache` internally,
but it was not reachable from the public API.

## Change

Added `VonMisesCdfModel(T)` with `init(mu, kappa)` and `cdf(x)`:

- `init` validates the parameters once and builds the
  `VonMisesCdfCache` table (null for `kappa = 0` or `kappa > 1e4`);
- `cdf` wraps the angle and evaluates the cached table, or falls back to
  the free `vonMisesRelativeCdf` path when no table exists;
- f32 and f64 are supported; the state is f64 internally.

The table path uses the quantile's sine recurrence, so values agree with
`vonMisesCdf` to about 4e-13 (worst at small kappa; `kappa >= 1000` is
bit-identical). The direct-sum public CDF remains the accuracy reference,
and the model's doc comment states the tolerance. The API reference
(`docs/api-reference.md`) records the three new symbols.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(the same `x` sweep and `(mu, kappa) = (0.5, 5)` on both sides), three
alternating pairs:

| Row | Baseline (M cdf/s) | Candidate (M cdf/s) |
| --- | --- | --- |
| `alea von mises cdf` vs model | 8.445, 9.814, 9.828 | 25.0, 21.0, 25.1 |

The model row is about 2.5x the free row (median 9.8M -> 25.0M), with the
identical checksum `2345.927`, which confirms the values agree at the
benchmark's precision.

## Accuracy

A grid over `x` from -3.141 to 3.141 (6283 points) and `kappa` in
{0.1, 0.5, 1, 2, 5, 20, 100, 1000, 1e4} measures the model-versus-free
difference:

- worst 3.6e-13 at `kappa = 0.5`; 7.2e-15 at `kappa = 0.1`;
- 3.8e-15 at `kappa = 5`, 9.0e-16 at `kappa = 20`;
- bit-identical for `kappa >= 1000`.

The new test checks the model against `vonMisesCdf` within 5e-13 over
`kappa` in {0, 0.5, 2, 20, 1e4, 1e5}, plus the f32 path, invalid
parameters, and NaN/infinite inputs.

## Validation

- `zig build test --summary all`: 29/29 steps, 997/997 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: `doccheck ok`.
- `zig build apicheck`: `apicheck ok` (new symbols recorded).

## Next Bar

The same model pattern is the next candidate for the wrapped skew-normal
CDF (~1.5x) and the runtime-shape skew CDF (~1.6x); the 1e9 background
run remains the next statistical bar.
