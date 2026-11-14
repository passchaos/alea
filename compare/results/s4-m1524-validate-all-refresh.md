# S4-M1524 Validate-All Refresh After S4-M1523

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1863/1863
tests with the 1000-iteration incomplete-beta continued fraction present:

- native `alea-tests` 918/918,
- WASI Node tests 918/918,
- distcheck (heavy-tail mean gates, Wishart gates, and long-run blocks
  included), distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 939/939 tests (native
918/918). No RNG stream changed in this milestone, so the reproducibility
matrix's sampler entries and benchmark checksums are unchanged; the
incomplete-beta diagnostics accuracy change is recorded in the versioned
distribution evidence table.
