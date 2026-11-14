# S4-M1485 Validate-All Refresh After S4-M1484

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1831/1831
tests with the scale-family extreme-parameter moment change present:

- native `alea-tests` 902/902,
- WASI Node tests 902/902,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 921/921 tests (native
902/902), `zig build statcheck` and `zig build distcheck` pass. No RNG stream
changed, so the reproducibility matrix and benchmark checksums are unaffected.
