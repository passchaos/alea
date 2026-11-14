# S4-M1487 Validate-All Refresh After S4-M1486

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1833/1833
tests with the extreme-scale closed-form CDF change present:

- native `alea-tests` 903/903,
- WASI Node tests 903/903,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 922/922 tests (native
903/903), `zig build statcheck` and `zig build distcheck` pass. No RNG stream
changed, so the reproducibility matrix and benchmark checksums are unaffected.
