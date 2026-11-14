# S4-M1452 Validate-All Refresh After S4-M1451

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1807/1807
tests with the one-setup HIN fill present:

- native `alea-tests` 890/890,
- WASI Node tests 890/890,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 909/909 tests (native
890/890), `roadmapcheck` passes, and the full 16MiB benchmark suite has 456
rows with zero pre-existing checksum differences (the two large-fill rows are
new).
