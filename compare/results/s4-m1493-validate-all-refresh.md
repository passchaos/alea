# S4-M1493 Validate-All Refresh After S4-M1492 and S4-M1494

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1841/1841
tests with the extreme-parameter sampling fixes present:

- native `alea-tests` 907/907,
- WASI Node tests 907/907,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 926/926 tests (native
907/907), `zig build statcheck` and `zig build distcheck` pass. The Triangular,
Kumaraswamy, and moderate-κ Von Mises streams are unchanged (the A/B checksums
in `s4-m1492-triangular-kumaraswamy-sampling.md` are identical), so the
reproducibility matrix and benchmark checksums are unaffected for normal
parameters.
