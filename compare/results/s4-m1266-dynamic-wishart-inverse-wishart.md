# S4-M1266 — Dynamic (runtime-dimension, allocator-backed) Wishart / Inverse-Wishart

## Goal

Add heap-allocated `Wishart(T)` and `InverseWishart(T)` structs for runtime-dimension p×p
positive-definite matrices, matching the existing `MultivariateNormal(T)` flat-row-major
allocator-backed pattern (`init(allocator, scale, df)`, `deinit`, `clone`, `sampleInto`
zero-alloc hot path, Checked variants).

## Implementation

### New public API

`Wishart(T)` — dynamic Wishart W_p(Ψ, ν), flat row-major scale `[]const T` of length p*p:

- `init(allocator, scale, df) !Self` / `new(...) !Self`
- `deinit(*Self)`
- `clone(self, allocator) !Self`
- `dfValue(self) T`, `dimensionValue(self) usize`
- `scaleValue(self, allocator) ![]T` (allocating) / `scaleInto(self, out) void` (caller buffer)
- `expectedValue(self, allocator) ![]T` / `expectedValueInto(self, out) void` (ν·Ψ)
- `modeValue(self, allocator) ?[]T` ((ν-p-1)·Ψ, null if ν ≤ p+1)
- `sample(self, allocator, rng) ![]T`, `sampleFrom(self, allocator, source) ![]T` (allocating)
- `sampleInto(self, rng, out)`, `sampleIntoFrom(self, source, out)` (zero-alloc)
- `sampleIntoChecked(self, rng, out) Error!void`, `sampleIntoCheckedFrom(self, source, out) Error!void`

`InverseWishart(T)` — dynamic Inverse-Wishart IW_p(Ψ, ν):

- Same method surface as Wishart.
- `expectedValue` / `modeValue` return `?[]T` (E[X] = Ψ/(ν-p-1) for ν>p+1; mode = Ψ/(ν+p+1)).

Scratch is pre-allocated at `init`; `sampleInto` performs **no allocation**:

- Wishart owns `cholesky` (L of Ψ), `scratch_A` (Bartlett A), `scratch_LA` (LA product).
- InverseWishart owns an inner `Wishart(T)` on Ψ⁻¹, `psi_chol`, `scratch_Linv`, `scratch_X`;
  during inversion it reuses `wishart.scratch_A` as L-scratch (saving one dim² buffer).

### Shared internal no-alloc flat-slice helpers

- `choleskyFactorizeFlat(T, dim, A, L) Error!void` — lower-triangular Cholesky on flat slices.
- `choleskyInvertFlatScratch(T, dim, L, Linv, out) void` — invert PD matrix from L, caller-owned Linv.
- `choleskyInvertMatrixFlatScratch(T, dim, A, L, Linv, out) Error!void` — factorize + invert with caller L/Linv.
- `wishartBartlettProductFlatScratch(T, dim, L, A, LA, out) void` — compute X = L·A·Aᵀ·Lᵀ.
- Allocating wrappers `choleskyInvertFlat` / `choleskyInvertMatrixFlat` / `wishartBartlettProductFlat`
  are provided for convenience but not used internally.

### Error handling and errdefer safety

- All allocating methods return inferred error set (`!Self` / `![]T`) — they can fail with
  `OutOfMemory` or the semantic `Error` set (`InvalidCovariance`, `InvalidLength`).
- `Wishart.init` allocates L, then A, then LA with individual errdefers (L must be freed
  if A fails; L+A if LA fails); on success all three are owned.
- `InverseWishart.init` allocates Lpsi, Linv, psi_inv (temporary), and X before constructing
  the inner Wishart. It uses `defer allocator.free(psi_inv)` to free the temporary unconditionally
  after wishart init (whether wishart init succeeds or fails) and `errdefer wishart_sampler.deinit()`
  to clean up the wishart if a later allocation (X) fails — preventing leaks in all partial-failure
  orderings.
- `clone` methods use matching errdefer chains (including `errdefer wishart_clone.deinit()`).

### Sampling algorithm (unchanged from static variants)

Rejection-free Bartlett decomposition:

1. Fill lower-triangular A with N(0,1) off-diagonals, √χ²(ν-i) on the diagonal.
2. X = L · A · Aᵀ · Lᵀ  (lower-triangular multiply with caller scratch LA).

Inverse-Wishart: draw X ~ W(Ψ⁻¹, ν) into scratch_X, then out = X⁻¹ via Cholesky inversion
reusing wishart.scratch_A as the L factor.

## Tests added (7 new, total 761)

1. `Wishart (dynamic) parameter validation` — rejects non-square length (5), ν<dim, non-PD scale, empty slice.
2. `Wishart (dynamic) 2x2 samples are PD, symmetric, mean matches` — 5000 Monte Carlo draws verify symmetry, positive definiteness (Cholesky succeeds), and sample mean ≈ ν·Ψ within tolerance.
3. `Wishart (dynamic) sampleInto and clone work` — `sampleInto` writes into caller buffer; cloned sampler draws independent samples; 3×3 scale.
4. `InverseWishart (dynamic) invalid parameters` — rejects non-square, ν<dim, non-PD scale.
5. `InverseWishart (dynamic) samples are PD and mean matches formula` — 5000 Monte Carlo draws verify symmetry/PD and E[X] ≈ Ψ/(ν-p-1).
6. `Wishart/InverseWishart (dynamic) sampleInto works with caller buffers` — zero-alloc sampleInto path, IW × W ≈ I identity product, f32 support.
7. f32 dynamic paths exercised within the existing test loops.

Seed constants: `0x9a2d`, `0x9a2e`, `0x9a2f`, `0x9a30`.

## Validation

- `zig build test` passes: 761/761 tests; all check gates (apicheck, readmecheck, toolingcheck,
  roadmapcheck, examplecheck) green.
- `docs/api-reference.md` updated with all 35 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1266 row added.

## Deviations and notes

- Matrices are flat row-major `[]T` of length dim² (Zig-idiomatic and matches
  `MultivariateNormal(T)` covariance handling), in contrast to Rust `nalgebra`-style
  statically-sized matrices. dim is inferred at runtime via `std.math.sqrt(scale.len)`
  and validated (dim² must equal scale.len exactly).
- `sampleIntoChecked` returns `Error!void` (semantic errors only, no `OutOfMemory`) since
  the hot path never allocates; out-of-memory can only occur at init/clone/allocation-returning
  methods where the inferred error set is used.
- Unlike `StaticInverseWishart`, the dynamic variant includes `deinit`/`clone`/`scaleInto`/
  `expectedValueInto`/`sampleInto` family to match `MultivariateNormal(T)` conventions;
  the static variant could be extended to match in a follow-up if needed.
