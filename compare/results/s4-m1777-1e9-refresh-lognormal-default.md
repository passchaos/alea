# S4-M1777 1e9 Long-Run Refresh After the LogNormal Default Change

Date: 2026-11-20

`alea-distcheck --long 1000000000` prints
`distlongcheck ok (1000000000 samples)` (about 64 minutes) after the S4-M1773
inlined-exponential LogNormal default change.

The run exercises the full 1e9 gate set with the new LogNormal mapping:

- continuous CDF means: `log-normal(1)=0.500017` against the exact 0.5,
  `beta(0.3)=0.579825`, `gamma(3)=0.450579`, `student-t(0)=0.499983`,
  `fisher-f(1)=0.534886`, `exponential(0.5)=0.632124`,
  `log-logistic(1.5)=0.499978`, `nakagami(2)=0.745235`,
  `ex-gaussian(2)=0.460424`, `inverse-gaussian(1)=0.627680`,
  `skew-normal(0)=0.250011`, `pert(0.5)=0.500010`, `rice(1)=0.396501`,
  `hoyt(1)=0.662988`;
- heavy-tail rates: `normal=0.002698`, `exponential=0.049782`,
  `student-t=0.030104` (expected 0.030099);
- 1% joint lower-tail copula rates: `gaussian=0.001875`,
  `student-t=0.003913`;
- the discrete CDF gates (binomial, Poisson, hypergeometric,
  negative-binomial, geometric, Zipf, Zeta, Bernoulli), the cached-binomial
  inversion/HIN CDFs, and the huge/rare-tail CDF gates.

The TRAE Zig guard's build-slot timeout does not apply because the ReleaseFast
`alea-distcheck` binary is run directly.

## Validation

- `alea-distcheck --long 1000000000`: `distlongcheck ok (1000000000 samples)`.
- `zig build test --summary all`: 995/995 (from S4-M1776).
- `zig build distcheck` / `statcheck`: pass.

## Next Bar

Keep the no-known-gaps comparison and long-run evidence current, and continue
the remaining Alea-only slow rows (wrapped skew-normal quantile,
vector-directional samplers).
