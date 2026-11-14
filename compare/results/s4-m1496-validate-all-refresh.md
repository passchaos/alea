# S4-M1496 Validate-All Refresh After S4-M1495

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1843/1843
tests with the Rice and Inverse-Gaussian huge-scale sampling change present:

- native `alea-tests` 908/908,
- WASI Node tests 908/908,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 927/927 tests (native
908/908), `zig build statcheck` and `zig build distcheck` pass. All
inverse-gaussian and normal-inverse-gaussian benchmark checksums are unchanged
(see `s4-m1495-rice-inverse-gaussian-huge-scales.md`), so the reproducibility
matrix is unaffected for normal parameters.
