# S4-M1491 Validate-All Refresh After S4-M1490

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1837/1837
tests with the Dirichlet huge-alpha sampling change present:

- native `alea-tests` 905/905,
- WASI Node tests 905/905,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 924/924 tests (native
905/905), `zig build statcheck` and `zig build distcheck` pass. The
finite-total Dirichlet path is byte-identical, so no RNG stream changed and
the reproducibility matrix and benchmark checksums are unaffected.
