# S4-M1471 Validate-All Refresh After S4-M1470

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1823/1823
tests with the hypergeometric edge-shaped inverse-transform fix present:

- native `alea-tests` 898/898,
- WASI Node tests 898/898,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 917/917 tests (native
898/898), and the full 16MiB benchmark suite has 457 rows with zero checksum
differences.
