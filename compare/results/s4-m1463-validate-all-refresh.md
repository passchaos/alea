# S4-M1463 Validate-All Refresh After S4-M1462

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1815/1815
tests with the large-parameter incomplete gamma/beta fallbacks present:

- native `alea-tests` 894/894,
- WASI Node tests 894/894,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 913/913 tests (native
894/894), and the full 16MiB benchmark suite has 457 rows with zero checksum
differences.
