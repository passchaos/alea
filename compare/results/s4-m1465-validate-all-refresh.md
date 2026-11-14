# S4-M1465 Validate-All Refresh After S4-M1464

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1817/1817
tests with the huge-population hypergeometric envelope present:

- native `alea-tests` 895/895,
- WASI Node tests 895/895,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 914/914 tests (native
895/895), and the full 16MiB benchmark suite has 457 rows with zero checksum
differences.
