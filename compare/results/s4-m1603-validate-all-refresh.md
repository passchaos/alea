# S4-M1603 Validate-All Refresh After S4-M1602

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1927/1927
tests with the GEV long-run gate present:

- native `alea-tests` 950/950,
- WASI Node tests 950/950,
- native and WASI distcheck (the default mode compiles the `checkLongRun`
  path containing the GEV mean/`cdf(3.0)` gates; the 1e9 execution evidence
  is S4-M1602),
- distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test distcheck --summary all` independently passes 971/971 tests
(native 950/950). Tooling-only milestone: no library code, sampling stream,
public API, or benchmark changed.
