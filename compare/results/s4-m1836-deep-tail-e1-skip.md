# S4-M1836 Skip the Deep Lower-Tail E1 Series in the Upper-Tail Wrappers

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile and CDF evaluate per-image upper-tail
terms `Q_sn(z) = 1 − Φ_sn(z)`. For `z < 0`, `alpha > 0`, `alpha·|z| >= 3.5`
the lower-tail CDF goes through `skewNormalLowerTailAsym`, whose E1
asymptotic series runs until its terms start growing — about `|z|` terms,
roughly 112 iterations at `z = −6.68` (the first image of the bench
configuration). That single term measured 118 ns, the most expensive part
of the ~150 ns image pass, and its result is below 1e-50: in f64 the upper
tail is exactly `1.0`.

## Change

All three upper-tail wrappers (`skewNormalUpperTailZ` and its 20/24-point
table variants) now return `1` directly when the asymptotic branch's factor
`exp(−(1+alpha²)z²/2)` is far below an ulp of 1 (`x > 69`, i.e. below
1e-30). The guard only fires in the same branch the asymptotic would take
(`alpha > 0`, `alpha·|z| >= 3.5`), and since `1 − Φ_sn(z)` already rounds to
`1.0` there, the shortcut is bit-identical — the bench checksums confirm it.

## Measurements

- Direct `wrappedSkewNormalQuantile(p, 0.4, 1, 2)` sweep: 856.8 ns → 671.5
  ns per call (about −22%) with an identical checksum.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), three alternating pairs:
  `wrapped skew-normal quantile` 1.224, 1.209, 1.183 M/s before and 1.462,
  1.463, 1.486 M/s after (median +21%); `wrapped skew-normal cdf` 5.385,
  4.316, 5.238 M/s before and 6.055, 5.642, 5.712 M/s after (median +9%).
  Both rows keep identical checksums.

## Accuracy

The shortcut returns the same f64 value the full path produces (the skipped
tail is below 1e-30 against a value that rounds to 1), so the S4-M1824
contract grid and the wrapped round-trip tests are unchanged.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 1.46M quantiles/s and its CDF
about 5.7M/s. Keep the no-known-gaps and long-run evidence current, and
revisit the large-hypergeometric codegen gap.
