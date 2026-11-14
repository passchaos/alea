# S4-M1489 Validate-All Refresh After S4-M1488

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1835/1835
tests with the ExGaussian exponent and tiny-shape quantile change present:

- native `alea-tests` 904/904,
- WASI Node tests 904/904,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 923/923 tests (native
904/904), `zig build statcheck` and `zig build distcheck` pass. No RNG stream
changed, so the reproducibility matrix and benchmark checksums are unaffected.
