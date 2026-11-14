# S4-M1516 Validate-All Refresh After S4-M1515

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1861/1861
tests with the Wishart/Inverse-Wishart batch APIs present:

- native `alea-tests` 917/917,
- WASI Node tests 917/917,
- distcheck (Wishart gates and long-run blocks included), distcheck-libc,
  statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 938/938 tests (native
917/917). No RNG stream changed in this milestone, so the reproducibility
matrix and benchmark checksums are unchanged.
