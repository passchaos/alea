# S4-M1450 Validate-All Refresh After S4-M1449

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1805/1805
tests with the new cached-binomial distcheck gates:

- native `alea-tests` 889/889,
- WASI Node tests 889/889,
- distcheck (now with the cached-binomial mean and long-run gates),
  distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 908/908 tests (native
889/889), and the 10M long run prints
`long cached binomial cdf: inversion(12)=0.575781 hin(100)=0.525774` and
`distlongcheck ok (10000000 samples)`.
