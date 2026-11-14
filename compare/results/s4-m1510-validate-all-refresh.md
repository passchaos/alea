# S4-M1510 Validate-All Refresh After S4-M1509

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1853/1853
tests with the long-run Wishart/Inverse-Wishart gates present:

- native `alea-tests` 913/913,
- WASI Node tests 913/913,
- distcheck (including the 20,000-sample Wishart gates and the new
  `checkLongRun` Wishart/Inverse-Wishart blocks), distcheck-libc, statcheck,
  and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 932/932 tests (native
913/913), `zig build distcheck` passes, and
`zig build distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)`. No RNG stream changed in this
milestone, so the reproducibility matrix and benchmark checksums are
unchanged.
