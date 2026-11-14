# S4-M1512 Validate-All Refresh After S4-M1511

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1857/1857
tests with the Dirichlet and Multinomial joint moment tests present:

- native `alea-tests` 915/915,
- WASI Node tests 915/915,
- distcheck (including the Wishart identity/non-diagonal gates and the
  `checkLongRun` Wishart/Inverse-Wishart blocks), distcheck-libc, statcheck,
  and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 934/934 tests (native
915/915). No sampling code or RNG stream changed in this milestone, so the
reproducibility matrix and benchmark checksums are unchanged.
