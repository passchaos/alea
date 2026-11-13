# S4-M1351 — Small log-factorial table for the HIN binomial

## Goal

Remove the per-call `lgamma` pairs from the HIN small-p binomial rejection
sampler, which dominated multinomial sampling where the conditional trials
count changes every draw.

## Implementation

- Added a comptime `binomial_log_factorial` table for `n < 513`, generated
  from the recurrence `log(n!) = log((n-1)!) + log(n)`, and an inline
  `binomialLogFactorial` helper that falls back to `std.math.lgamma` for
  larger arguments.
- `binomialRejectionSmallPFrom` now computes its setup `lf` and its
  acceptance `lfx` from the table. All HIN integer arguments are exactly
  integer-valued (`np = floor(t*p)`, `t - np`, `kf = np + x`), so the lookup
  is exact.
- The waiting-time tail, proposal distributions, acceptance inequalities, and
  draw order are unchanged; only the log-factorial evaluation changed.
- No public API change and no new allocation; the table is 4 KiB of rodata.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host focused A/B runs at the previous commit and with the change:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea multinomial` | 2.6M samples/s | 6.3M samples/s | +142% |
| `alea multinomial direct` | 2.8M samples/s | 6.7M samples/s | +139% |
| `alea multinomial many direct` | 2.8M samples/s | 6.7M samples/s | +139% |
| `alea binomial large` (`n = 10000`) | 7.0M samples/s | 11.3M samples/s | +61% |

Every benchmark checksum is identical before and after the change, so the
sampled streams for these parameter sets are unchanged. Other binomial-family
rows (`binomial`, `fillBinomial`, `negative-binomial`, `hypergeometric`,
`beta binomial`) stay within run-to-run noise because their benchmark loops
use constant parameters that the compiler hoists; the table helps
runtime-varying calls such as the multinomial conditionals.

## Validation

- `zig build test` passes 898/898, including all binomial, multinomial,
  negative-binomial, hypergeometric, and beta-binomial tests.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further multinomial or vector-directional kernel optimization, or newly
discovered core gaps.
