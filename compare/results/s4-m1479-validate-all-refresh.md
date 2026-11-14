# S4-M1479 Validate-All Refresh After S4-M1478

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1825/1825
tests with the huge-population hypergeometric CDF/quantile change present:

- native `alea-tests` 899/899,
- WASI Node tests 899/899,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 918/918 tests (native
899/899), `zig build statcheck` and `zig build distcheck` pass, and the 10M
long run prints `distlongcheck ok (10000000 samples)` with the new
huge-population CDF gates. No RNG stream changed, so the reproducibility
matrix and benchmark checksums are unaffected.
