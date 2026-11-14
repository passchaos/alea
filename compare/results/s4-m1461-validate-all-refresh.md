# S4-M1461 Validate-All Refresh After S4-M1460

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1813/1813
tests with the huge-parameter binomial CDF fallbacks present:

- native `alea-tests` 893/893,
- WASI Node tests 893/893,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

The first refresh attempt exposed that the new test asserted 1e18-trial
quantiles on wasm32, where the bisection's `usize` index cannot represent
them; guarding those assertions on `@sizeOf(usize) >= 8` (commit `35d35a2b`)
restored the WASI suite. `zig build test --summary all` independently passes
912/912 tests (native 893/893), and the full 16MiB benchmark suite has 457
rows with zero checksum differences.
