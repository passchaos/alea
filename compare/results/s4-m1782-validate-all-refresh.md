# S4-M1782 Validate-All Refresh After the Batched Engine Fills

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the S4-M1781 four-word batched engine fills (and the
S4-M1780 ChaCha zeroing removal):

- native and WASI unit suites, including the engine snapshot/stream-shape
  tests that pin the emitted word order and the `fill-only` tail byte;
- native and WASI distcheck with the continuous/tail/copula gates, the scalar
  and vector binned chi-square gates, and the discrete CDF gates;
- distcheck-libc, statcheck, profilecheck (long/stress/tail), the PractRand
  self-test, the six crosscheck targets, and the chained WASI report.

No library code changed in this milestone. The batched fills keep the engine
streams unchanged, so no reproducibility-matrix mapping update is needed.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1979/1979 tests.

## Next Bar

Keep the no-known-gaps comparison and long-run evidence current, and only land
further micro-optimizations when a same-host A/B clears the host noise floor.
