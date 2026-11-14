# S4-M1454 Validate-All Refresh After S4-M1453

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1809/1809
tests with the shared negative-binomial fill rate present:

- native `alea-tests` 891/891,
- WASI Node tests 891/891,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 910/910 tests (native
891/891), and the full 16MiB benchmark suite has 456 rows with zero checksum
differences.
