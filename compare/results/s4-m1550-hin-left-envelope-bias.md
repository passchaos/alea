# S4-M1550 HIN Left-Envelope Mean Bias

Date: 2026-11-15

## Gap

S4-M1474 measured a pre-existing `+0.015` absolute mean offset in the HIN
small-`p` binomial rejection sampler for means `16..1000` and left the
envelope as future work. The long-run gate tolerated it as `[19.9, 20.1]`.

## Root Cause

HIN's logarithmic rejection is exact when each region's envelope dominates
the target PMF, because the region selection probabilities and proposal
constants are paired so that `p_r · const_r` is uniform. The left-side
(region 2) half-normal envelope `e^{−y²/(2s2²)}` is below the target for the
nearly flat cells just below the mode: for small `p`,
`P(np−1)/P(np) → 1` (Poisson-like), while the envelope drops to
`e^{−1/(2s2²)}` after one cell. Those cells are under-weighted, which shifts
mass to the right and produces the `+0.015` mean bias. The right-side
envelope does not have the problem because it carries the `e^c` height
factor; the left side had no equivalent offset.

## Change

- `BinomialHinSetup` gains `c2 = c/4`, added to the region-2 rejection
  height (`v = −E − N²/2 + c2`).
- The region-2 mass term becomes `e^{c2}·s2·√(π/2)`, keeping the
  `p_r · const_r = 1/s` normalization uniform, so the sampler remains exact
  once the envelope dominates.
- `distcheck` adds a 4e6-draw `binomial(1e18, 2e-17)` mean gate at
  `[19.992, 20.008]`; the former `+0.015` offset sits ~6.7 standard errors
  outside it. The 1e9-sample long-run gate tightens from `[19.9, 20.1]` to
  `[19.95, 20.05]`.
- The HIN draw stream changes for the affected small-`p` region; this is a
  deliberate correctness change and the only stream contract touched.

## Validation

- An exact acceptance-mass model of the algorithm (integrating
  `min(e^{envelope}, e^{target})` per cell with the region weights)
  reproduces the measured offset: `t = 1000, p = 0.02` gives `20.013915`,
  `t = 1e6, p = 2e-5` gives `20.016705`, and `t = 100, p = 0.2` gives
  `20.001812`. With `c2 = c/4` the model returns exactly `20.000000` for all
  of them.
- A dominance grid (66 parameter sets over `trials ∈ {100, …, 1e18}`,
  means `16..5000`, and `p ∈ {0.01, 0.05, 0.1, 0.25, 0.49}`) finds 2363
  violating cells in 53/66 sets without the offset and zero violations with
  `c2 = c/4`; separate wide-span checks at `p = 0.49` and `trials = 1e18`
  also show zero violations.
- Zig multi-seed probes at `binomial(1e18, 2e-17)` with 10M draws per seed
  measure `19.999203`, `19.998842`, `19.997951`, and `20.000393`
  (standard error `0.0014`) against the former `20.015`.
- `zig build test --summary all` passes 954/954 (native 935/935);
  `distcheck` (including the new 4e6-draw gate) passes; `doccheck` passes.

The aggregate `validate-all` refresh is tracked as the following milestone.
