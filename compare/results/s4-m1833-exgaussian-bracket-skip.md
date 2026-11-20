# S4-M1833 Skip the Ex-Gaussian Bracket Verification

Date: 2026-11-20

## Gap

`exGaussianQuantileImpl` starts from a fixed bracket `mu ± 40·spread` and then
verified it with two full CDF evaluations before the Halley loop:
`exGaussianCdf(lo) > p` and `exGaussianCdf(hi) < p`. That bracket cannot
fail in f64: the left tail is Gaussian at 40 sigma or more (the CDF
underflows to 0), and the right tail is bounded by `exp(-40)` because
`spread >= tau`, so the CDF at the upper endpoint rounds to 1. The two
verification evaluations were therefore dead work on every call — roughly
half of the 215 ns quantile.

## Change

The verification loops now run only when `1 - p < 1e-12`, the only range
where a target can fall outside the saturated bracket. For the ordinary
range the quantile starts the Halley loop directly from the 40-spread
bracket.

## Accuracy

A round-trip audit over `mu ∈ {0, 0.5, 1, 2}`, `sigma ∈ {0, 0.3, 1, 5}`,
`tau ∈ {0.01, 0.5, 1, 3}`, and `p` from 1e-300 to `1 − 1e-16` gives a worst
`|CDF(quantile(p)) − p|` of 2.14e-14; the gate only changes which calls pay
the verification, not the result.

## Measurements

- Direct `exGaussianQuantile(p, 0, 1, 1)` sweep over 2M probabilities
  (best of five trials): 214.8 ns before, 166.1 ns after (about −23%) with
  an identical checksum.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`) in a quiet window, six
  alternating pairs: `ex-gaussian quantile` 5.173, 5.175, 5.186, 5.181,
  5.179, 5.183 M/s before and 5.911, 5.919, 5.936, 5.929, 5.933, 5.894 M/s
  after. Every pair favors the change; the median moves from 5.180M to
  5.926M (about +14%) with identical checksums (`3883.020`).

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The same "verified guaranteed bracket" pattern does not appear in the other
quantiles (their initial upper bounds are not guaranteed and must be
checked); the inverse-Gaussian variant was measured and gave no win. Keep
the no-known-gaps and long-run evidence current, and revisit the
large-hypergeometric codegen gap.
