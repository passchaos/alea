# S4-M1776 1e7 Long-Run Refresh After the LogNormal Default Change

Date: 2026-11-20

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)` after the S4-M1773 inlined-exponential
LogNormal default change.

The run exercises the full long gate set with the new LogNormal mapping,
including the continuous CDF means (`log-normal(1)=0.500164` against the exact
0.5), the heavy-tail rates, the copula lower-tail rates, the scalar/vector
binned chi-square gates, and the discrete CDF gates. The LogNormal sampling
stream changed as a deliberate versioned mapping change; the statistical gates
confirm the new transform has the same distribution.

Neutral experiments this turn:

- routing the `poisson(rng, lambda)` facade through the free `poissonFrom`
  was neutral (85.9M vs 89.6M samples/s, unchanged checksum) and was reverted;
- routing `vectorGammaFrom` through the per-lane free `gammaFrom` moved the
  `vector gamma f64x4` row from 42.6M to 43.1M vectors/s (+1.2%, unchanged
  checksum) — too marginal to keep and was reverted.

## Validation

- `alea-distcheck --long 10000000`: `distlongcheck ok (10000000 samples)`.
- `zig build test --summary all`: 995/995 (from S4-M1775).
- `zig build distcheck` / `statcheck`: pass.

## Next Bar

Refresh the 1e9 evidence for the new LogNormal mapping and continue the
remaining Alea-only slow rows.
