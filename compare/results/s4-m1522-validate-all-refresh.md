# S4-M1522 Validate-All Refresh After S4-M1521

Date: 2026-11-15

`zig build validate-all --summary all` passes 124/124 steps and 1861/1861
tests with the heavy-tail sampler mean gates present:

- native `alea-tests` 917/917,
- WASI Node tests 917/917,
- distcheck with the nine new pareto/generalized-pareto/inverse-gamma/
  scaled-inverse-chi-squared/ex-gaussian/triangular/nakagami/rice/hoyt mean
  gates, plus the Wishart gates and long-run blocks, distcheck-libc,
  statcheck, and profilecheck,
- the PractRand self-test,
- all six crosscheck targets,
- the chained WASI report.

`zig build test --summary all` independently passes 938/938 tests (native
917/917). No library code or RNG stream changed in this milestone, so the
reproducibility matrix and benchmark checksums are unchanged.
