# S4-M1502 Validate-All Refresh After S4-M1501

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1847/1847
tests with the Chi and NoncentralChi huge-parameter moment fix present:

- native `alea-tests` 910/910,
- WASI Node tests 910/910,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 929/929 tests (native
910/910), `zig build statcheck` and `zig build distcheck` pass. The changed
helpers are deterministic moment functions, so no RNG stream changed.
