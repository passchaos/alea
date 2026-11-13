# S4-M1379 — Reproducibility matrix refresh for the versioned batch

## Goal

Keep `compare/results/reproducibility-matrix.md` current for the versioned
distribution stream changes landed in S4-M1349 through S4-M1377, as required
by the statistical-confidence track.

## Change

- Expanded the versioned "Non-uniform distributions and reusable distribution
  samplers" row to enumerate this batch's stream changes: exact 3×2 and
  single-column matrix vMF sampling, direct unit-circle tangent assembly for
  Watson/vMF, Zipf log-space acceptance, Weibull/Frechet/Pareto exp/log
  transforms, HIN binomial ziggurat exponentials with Stirling/table
  log-factorials, Bingham `@log` acceptance and precomputed proposal scales,
  the vectorized Student-t copula CDF, and the multinomial batch HIN cache.
- Added a "Versioned Distribution Change Evidence" table mapping each change
  to its `compare/results/s4-m13xx-*.md` evidence file.
- The stable-output contracts (engines, uniform/ranged sampling, seed
  derivation, iterators, strings) are unchanged.

## Notes

- These are versioned distribution changes, not stable-output breaks: the
  matrix already classifies non-uniform distributions as deterministic but
  upgradeable, and every change above is documented with before/after
  benchmark and validation evidence in its evidence file.
- The single-sample multinomial breakdown recorded in
  `performance-triage.md` shows the HIN setup/acceptance loop remains the
  dominant cost; future work should target that kernel rather than the
  multinomial wrapper.

## Validation

- No source change; `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes and the 10M long run passes.
