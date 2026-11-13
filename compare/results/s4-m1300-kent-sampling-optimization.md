# S4-M1300 — Kent sampling optimization

## Goal

Raise `Kent(T)` sampling throughput without changing its distribution. The
S4-M1299 benchmark recorded 10.0 M samples/s for `alea kent 3d`; the sampler
was spending most of its time on rejected joint proposals.

## Changes

### Conditional marginal/angle decomposition

The joint rejection sampler proposed `(w, φ)` together from a vMF point and
rejected on `β(1−w²)cos(2φ)`. It accepted about 31% of proposals for the
benchmark parameters. The sampler now uses the exact factorization

```
p(w)    ∝ exp(κw)·I₀(β(1−w²)),
p(φ|w)  ∝ exp(β(1−w²)·cos(2φ)),
```

- `w` is proposed from the mean-matched vMF marginal using Wood's algorithm and
  accepted against `exp((κ−λ)w)·I₀(β(1−w²))`, whose supremum is computed once
  at construction by a coarse grid plus golden-section refinement in log space.
  For the benchmark parameters this raises the `w` acceptance rate to about
  94%.
- `φ` is drawn from the conditional von Mises density by sampling
  `θ ~ vMF(0, β(1−w²))` and setting `φ = θ/2`.

### In-frame sampling and precomputed constants

- The proposal cosine `w` and tangent angle `φ` are sampled directly in the
  Kent frame; no full 3D vMF point is constructed and no Householder reflection
  or projection dot products are needed.
- Wood's `b`, `x0`, and `c` constants are precomputed in `Kent.init` instead of
  being rebuilt on every proposal.
- The tangent point is assembled only after acceptance.

### Symmetry bug found during development

The conditional density `exp(a·cos(2φ))` has period π, but `θ ~ vMF(0, a)`
covers only one half-period of `φ`. The first version therefore biased the
tangent direction toward `γ₂` (observed sample mean 0.414 instead of 0). The
fix replicates the sampled half-period to the full circle with a random π shift,
restoring `E[γ₂ᵀx] = E[γ₃ᵀx] = 0`.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "kent"`

| Revision | M samples/s |
| --- | ---: |
| S4-M1299 joint rejection | 10.0 |
| S4-M1300 conditional sampler | 14.4 |

The optimized sampler is about 44% faster and the checksum changed because the
sampler consumes the RNG stream differently (the distribution is unchanged).

## Validation

- `zig test src/root.zig --test-filter "Kent"` passes 7/7, including the
  40,000-sample mean/covariance recovery and the zero tangent-mean symmetry
  check that caught the half-period bug.
- `zig build distcheck` passes with the Kent moment/anisotropy/trace gates.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `zig build test --summary all` passes 852/852 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1300 row added.

## Next bar

Matrix von Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, longer
statistical validation runs, or newly discovered core gaps against local Rust
`rand` / `rand_distr` evidence.
