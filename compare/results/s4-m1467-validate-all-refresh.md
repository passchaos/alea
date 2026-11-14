# S4-M1467 Validate-All Refresh After S4-M1466

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1819/1819
tests with the gamma-Poisson negative-binomial mixture present:

- native `alea-tests` 896/896,
- WASI Node tests 896/896,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 915/915 tests (native
896/896), and the full 16MiB benchmark suite has 457 rows with zero checksum
differences.
