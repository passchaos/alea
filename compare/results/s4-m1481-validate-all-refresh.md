# S4-M1481 Validate-All Refresh After S4-M1480

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1827/1827
tests with the beta-family extreme-parameter stability change present:

- native `alea-tests` 900/900,
- WASI Node tests 900/900,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 919/919 tests (native
900/900), `zig build statcheck` and `zig build distcheck` pass, and the 1M
long run prints `distlongcheck ok (1000000 samples)`. No RNG stream changed,
so the reproducibility matrix and benchmark checksums are unaffected.
