# S4-M1526 Validate-All Refresh After S4-M1525

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1865/1865
tests with the 1000-iteration incomplete-gamma series present:

- native `alea-tests` 919/919,
- WASI Node tests 919/919,
- distcheck (heavy-tail mean gates, Wishart gates, and long-run blocks
  included), distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 940/940 tests (native
919/919). No RNG stream changed in this milestone; the incomplete-gamma
diagnostics accuracy change is recorded in the versioned distribution
evidence table.
