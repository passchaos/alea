# S4-M1849 Tighten the Deep-Tail Fast-Path Threshold

Date: 2026-11-20

## Gap

S4-M1836 added a fast path to the upper-tail wrappers: when the asymptotic
lower-tail factor `exp(−(1+alpha²)z²/2)` is below an ulp of 1, `Q_sn(z)` is
exactly `1.0` and the E1 series (about `|z|` terms) can be skipped. The
threshold was set conservatively at `x > 69` (factor below 1e-30). The
actual requirement is `Φ_sn < 5e-17` (half an ulp of 1), and
`Φ_sn ≈ 0.08·e^{−x}/x`, so `x > 36` already gives about 5e-19.

That left a wide band — for `alpha = 2`, images with `|z|` between 3.8 and
5.3 — still paying the full E1 series even though their result rounds to
exactly 1.

## Change

The threshold drops from 69 to 36 in all three upper-tail wrappers
(`skewNormalUpperTailZ` and its 20/24-point table variants). The guard still
only fires inside the asymptotic branch, and the returned value is the same
f64 the full path produces.

## Measurements

- Direct `wrappedSkewNormalQuantile(p, 0.4, 1, 2)` sweep: 473.2 ns → 395.9
  ns per call (about −16%) with an identical checksum.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `wrapped skew-normal quantile` 1.034, 1.095, 1.074, 1.052 M/s before and
  2.361, 2.393, 2.092, 2.278 M/s after (median 1.063M to 2.320M, about
  +118%); `wrapped skew-normal cdf` moves from a 5.503M median to 5.641M
  (about +2.5%, two of four pairs in a noisy window).

## Accuracy

Bit-identical: the fast path returns exactly `1.0`, which is the value the
full asymptotic path already rounds to at `x > 36`; the direct-sweep
checksum is unchanged.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 2.3M quantiles/s. Keep the
no-known-gaps and long-run evidence current; the large-hypergeometric
codegen gap (0.86-0.87x) remains the only sub-parity comparable workload.
