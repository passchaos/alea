# S4-M1499 Validate-All Refresh After S4-M1498 and S4-M1500

Date: 2026-11-14

`zig build validate-all --summary all` passes 124/124 steps and 1845/1845
tests with the long-run extreme-CDF gates and the beta-binomial extreme-shape
fixes present:

- native `alea-tests` 909/909,
- WASI Node tests 909/909,
- distcheck, distcheck-libc, statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 928/928 tests (native
909/909), `zig build statcheck` and `zig build distcheck` pass. No RNG stream
changed: the beta-binomial helpers are deterministic diagnostics.
