# S4-M1779 Validate-All Refresh After the Facade f32 Fill

Date: 2026-11-20

`zig build validate-all --summary all` passes 124/124 steps and 1979/1979
tests, including native `alea-tests` 976/976 and WASI Node tests 976/976.

The run covers the S4-M1778 facade-aware f32 standard-normal fill (and the
S4-M1773..M1777 LogNormal default and long-run work):

- native and WASI unit suites, including the f32 fill stream-shape tests;
- native and WASI distcheck with the continuous/tail/copula gates, the scalar
  and vector binned chi-square gates, and the discrete CDF gates;
- distcheck-libc, statcheck, profilecheck (long/stress/tail), the PractRand
  self-test, the six crosscheck targets, and the chained WASI report.

No library code changed in this milestone.

## Measurement note

The host is shared with other concurrent TRAE sessions, and this turn's
sub-5% experiments (`vectorGammaFrom` / `vectorChiSquaredFrom` per-lane free
routing) could not be distinguished from run-to-run noise: repeated runs of the
same row varied by 10-15% (for example `vector chi-squared f64x4` measured 43.3,
42.6, and 38.6M vectors/s across runs). Those changes were reverted rather than
landed on weak evidence. Larger deltas (the 1.4-1.5x f32 fill win) remain
clearly separable from this noise.

## Validation

- `zig build validate-all --summary all`: 124/124 steps, 1979/1979 tests.

## Next Bar

Keep the no-known-gaps comparison and long-run evidence current, and only land
further micro-optimizations when a same-host A/B clears the host noise floor.
