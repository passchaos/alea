# S4-M1595 Validate-All Refresh After S4-M1594

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1915/1915
tests with the standard-error-scaled long-run directional gates present:

- native `alea-tests` 944/944,
- WASI Node tests 944/944,
- native and WASI distcheck (the default mode compiles and runs the
  `checkLongRun` code path containing `longMeanTolerance`; the long-mode
  evidence itself is the 1e9 run recorded in S4-M1594),
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 965/965 tests
(native 944/944). Tooling-only milestone: no library code, sampling stream,
public API, or benchmark changed.
