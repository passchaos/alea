# S4-M1508 Validate-All Refresh After S4-M1507

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1853/1853
tests with the full Bartlett `L·A` Wishart product and its new gates present:

- native `alea-tests` 913/913,
- WASI Node tests 913/913,
- distcheck (including the new Wishart identity off-diagonal, non-diagonal
  mean, and off-diagonal variance gates), distcheck-libc, statcheck, and
  profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 932/932 tests (native
913/913), and `zig build statcheck`/`distcheck` pass. The Wishart and
Inverse-Wishart stream change is the intended versioned correction recorded in
the reproducibility matrix.
