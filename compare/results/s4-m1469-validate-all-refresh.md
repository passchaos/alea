# S4-M1469 Validate-All Refresh After S4-M1468

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1821/1821
tests with the huge fair-binomial HIN fallback present:

- native `alea-tests` 897/897,
- WASI Node tests 897/897,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 916/916 tests (native
897/897), and the full 16MiB benchmark suite has 457 rows with zero checksum
differences.
