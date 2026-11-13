# S4-M1326 — Diagnostics example CDF/quantile coverage

## Goal

Extend the runnable distribution-diagnostics example so the newly added
closed-form CDF/quantile helpers and sampler-level methods are discoverable
and verified end to end.

## Changes

`examples/distribution_diagnostics.zig` now prints:

- `Laplace(0,1)`: `cdf(1)=0.816060`, `quantile(0.9)=1.609438`,
- `Weibull(1,2)`: `cdf(1)=0.632121`, `quantile(0.5)=0.832555`,
- `Triangular(0,0.5,1)`: `cdf(0.25)=0.125000`, `quantile(0.5)=0.500000`,
- `Kumaraswamy(2,3)`: `cdf(0.5)=0.578125`, `quantile(0.5)=0.454202`,
- free helpers: `frechetCdf(1; 0,1,2)=0.367879` and
  `paretoQuantile(0.5; 1,2)=1.414214`.

`tools/examplecheck.zig` catalogs the new source tokens, and
`docs/examples.md` describes the added diagnostics coverage.

## Validation

- `zig build run-distribution-diagnostics` prints the values above.
- `zig build test --summary all` passes 881/881 tests, including
  `examplecheck`, `toolingcheck`, `readmecheck`, and `roadmapcheck`.
- `compare/results/core-rand-coverage.md` S4-M1326 row added.

## Next bar

O(3) matrix Fisher reflections, further vector compaction/squeeze
optimizations, broader platform runners, or newly discovered core gaps.
