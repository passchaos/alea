# S4-M1309 — SIMD von Mises and von Mises-Fisher sampling

## Goal

Add true SIMD directional sampling. While inspecting the existing
`VectorVonMises` surface, it turned out to be unusable: it delegated to the
scalar `vonMisesFrom`, which calls scalar-only `Rng.floatOpenFrom` and uses
scalar `if`/`assert` conditions, so instantiating it for a vector type failed
to compile. This milestone fixes that path and adds a SIMD vMF sampler on S².

## Changes

### SIMD circular von Mises

`vonMisesFrom` now dispatches to `vonMisesVectorFrom` for vector types. The
per-lane Best–Fisher sampler:

- handles `κ = 0` lanes with a vector uniform draw,
- evaluates the squeeze and log-ratio acceptance tests per lane,
- retires accepted lanes and keeps drawing only unresolved lanes,
- returns one independent von Mises sample per lane.

### SIMD von Mises-Fisher on S²

`VectorVonMisesFisher(VectorType)` samples `[3]VectorType`, with one
independent vMF sample per lane and a mean direction/concentration shared
across lanes:

- Wood's cosine rejection is evaluated per lane with lane retirement,
- the tangent angle is drawn uniformly per lane,
- the e₁-frame point is Householder-reflected to the shared mean direction,
- `κ = 0` delegates to `vectorUnitSphereFrom`, and `κ > 1e12` returns the
  mean direction in every lane.

Free functions: `vectorVonMisesFisher`, `vectorVonMisesFisherFrom`,
`vectorVonMisesFisherChecked`, `vectorVonMisesFisherCheckedFrom`,
`fillVectorVonMisesFisher`, `fillVectorVonMisesFisherFrom`,
`fillVectorVonMisesFisherChecked`, `fillVectorVonMisesFisherCheckedFrom`.

## Tests added (5 new, total 867)

1. `VectorVonMises` f64x4: `E[cos θ] = I₁(2)/I₀(2)` and `E[sin θ] = 0`.
2. `VectorVonMises` κ=0 uniformity and f32x8 moments.
3. `VectorVonMisesFisher` f64x4: per-lane unit norms, zero x/y means, and
   `E[z] = coth(5) − 1/5`.
4. `VectorVonMisesFisher` κ=0 uniformity and f32x8 unit norms/mean.
5. Free functions, fills, and checked error paths.

## Validation

- `zig test src/root.zig --test-filter "VectorVonMises"` passes 2/2 and
  `--test-filter "VectorVonMisesFisher"` passes 3/3.
- `zig build test --summary all` passes 867/867 tests; `apicheck` and all
  documentation gates are green.
- `docs/api-reference.md` updated for all 19 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1309 row added.

## Next bar

Vector vMF docs/distcheck/benchmark integration, SIMD Kent/Watson/Bingham
sampling, or newly discovered core gaps.
