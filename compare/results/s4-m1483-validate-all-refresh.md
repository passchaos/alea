# S4-M1483 Validate-All Refresh After S4-M1482

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1829/1829
tests with the fading/noncentral extreme-parameter moment change present:

- native `alea-tests` 901/901,
- WASI Node tests 901/901,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 920/920 tests (native
901/901), `zig build statcheck` and `zig build distcheck` pass. No RNG stream
changed, so the reproducibility matrix and benchmark checksums are unaffected.
