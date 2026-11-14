# S4-M1448 Validate-All Refresh After S4-M1447

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1805/1805
tests with the one-uniform inverse-CDF cached binomial sampler present:

- native `alea-tests` 889/889,
- WASI Node tests 889/889,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 908/908 tests (native
889/889), `apicheck` and `roadmapcheck` pass, and the full 16MiB benchmark
suite has 454 rows with zero pre-existing checksum differences (the two
mean-12 runtime rows are new; the mean-100 HIN pair keeps `6552418`).
