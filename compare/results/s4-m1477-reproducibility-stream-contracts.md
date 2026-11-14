# S4-M1477 Reproducibility Matrix Refresh for the Extreme-Parameter Batch

Date: 2026-11-14

## Change

The versioned-stream table in `reproducibility-matrix.md` now records the
extreme-parameter batch:

- huge-trial binomial sampler and huge-parameter binomial CDF
  (`s4-m1458`, `s4-m1460`),
- huge fair-binomial HIN dispatch for `p = 0.5`, `trials > 4096`
  (`s4-m1468`),
- negative-binomial gamma-Poisson mixture for `successes >= 2^20`
  (`s4-m1466`),
- huge-population hypergeometric H2PE and inverse-transform init
  (`s4-m1464`, `s4-m1470`),
- large-parameter incomplete gamma/beta CDF fallbacks (`s4-m1462`).

The existing "stream-preserving speedups (identical checksums)" row now also
lists the one-setup HIN fill (`s4-m1451`) and the shared negative-binomial
fill rate (`s4-m1453`).

## Contract

Normal-parameter sampler streams are unchanged: the full 16MiB benchmark
suite keeps all 457 checksums identical across the batch. The listed
extreme-parameter paths define new stable streams (tiny `p`, huge trials,
`p = 0.5` above 4096 trials, `successes >= 2^20`, populations at or above
1e12, and CDFs with shape parameters at or above the fallback thresholds).

## Validation

- `zig build roadmapcheck` passes.
- Docs-only change: no source, tests, or benchmarks changed.
