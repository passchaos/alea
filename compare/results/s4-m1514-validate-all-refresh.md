# S4-M1514 Validate-All Refresh After S4-M1513

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1859/1859
tests with the peer-type diagnostics wrappers present:

- native `alea-tests` 916/916,
- WASI Node tests 916/916,
- distcheck (Wishart gates and long-run blocks included), distcheck-libc,
  statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 935/935 tests (native
916/916). No sampling code or RNG stream changed in this milestone, so the
reproducibility matrix and benchmark checksums are unchanged.
