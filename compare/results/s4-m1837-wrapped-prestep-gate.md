# S4-M1837 Gate the Wrapped Quantile Pre-Step by the Wrap Mass

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile refines its seed with a Halley step on the
*unwrapped* skew-normal CDF. That step costs about 60 ns (a table CDF plus
the density pair). Since S4-M1835 the seed itself is the moment-matched
skew-normal start, so the step only pays off when the wrapped root is close
to the unwrapped one — that is, when the mass beyond the `±pi` cut is
negligible. A per-configuration profile showed it saves a full iteration at
`sigma = 0.5` but is neutral at `sigma = 1` (the bench configuration) and
saves only 0.1-0.15 iterations at `sigma = 2`.

## Change

The pre-step now runs only for `sigma <= 0.75`, where the wrap mass is below
about 3e-5 (`2·Φ(−π/σ) = 2.8e-5` at the threshold). The seed, trust region,
and iteration logic are unchanged for every other case.

## Measurements

- Direct `wrappedSkewNormalQuantile(p, 0.4, 1, 2)` sweep: 671.5 ns → 596.6
  ns per call (about −11%).
- Iteration profile across configurations (mean iterations): `sigma = 0.5,
  alpha = 1` keeps its pre-step at 2.05 (3.05 without); `sigma = 1, alpha =
  2` is 3.14 (3.16 with); `sigma = 2` configurations drop the 60 ns step for
  at most +0.12 iterations; `sigma = 1, alpha = −2` is the one regression at
  3.63 (3.01 with), about +20 ns net.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), three alternating pairs:
  `wrapped skew-normal quantile` 1.428, 1.236, 1.252 M/s before and 1.333,
  1.288, 1.328 M/s after (median +6%, two of three pairs).

## Accuracy

The S4-M1824 contract grid is unchanged at 5.49796e-11 worst round-trip
error; only the seed path differs, and the loop still converges to the same
floor.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 1.3-1.5M quantiles/s. Keep
the no-known-gaps and long-run evidence current, and revisit the
large-hypergeometric codegen gap.
