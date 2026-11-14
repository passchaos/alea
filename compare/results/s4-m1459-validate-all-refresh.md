# S4-M1459 Validate-All Refresh After S4-M1458

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1811/1811
tests with the huge-trial tiny-p binomial fix present:

- native `alea-tests` 892/892,
- WASI Node tests 892/892,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 911/911 tests (native
892/892), and the full 16MiB benchmark suite has 457 rows with zero checksum
differences.
