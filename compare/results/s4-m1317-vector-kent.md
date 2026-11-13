# S4-M1317 — SIMD Kent sampling

## Goal

Complete the SIMD directional family with a per-lane Kent (Fisher-Bingham F5)
sampler on S².

## Implementation

`VectorKent(VectorType)` stores the scalar `Kent(T)` sampler (frame,
concentration, ovalness, proposal λ, marginal envelope, Wood constants) and
samples `[3]VectorType` with one independent sample per lane:

- `w` is proposed from the mean-matched vMF marginal with a per-lane Wood
  rejection and accepted against
  `exp((κ−λ)w)·I₀(β(1−w²)) / exp(max_log)`; the scalar `logBesselI0` is
  evaluated lane by lane into a vector.
- `φ` is drawn from the conditional von Mises density using the per-lane
  vector von Mises sampler (`a = β(1−w²)` varies by lane), then replicated to
  the full circle with a per-lane random π shift.
- The point is assembled directly in the Kent frame:
  `x = w·γ₁ + √(1−w²)(cosφ·γ₂ + sinφ·γ₃)`; no Householder reflection is
  needed.
- `β = 0` delegates to `VectorVonMisesFisher` (bit-for-bit parity), `κ = 0`
  is uniform, and `κ > 1e12` is a point mass at the mean direction.

Free functions: `vectorKent`, `vectorKentFrom`, `vectorKentChecked`,
`vectorKentCheckedFrom`, `fillVectorKent`, `fillVectorKentFrom`,
`fillVectorKentChecked`, `fillVectorKentCheckedFrom`.

## Tests added (3 new, total 876)

1. **f64x4 moments** — 40,000 lane samples; mean `z` matches the scalar Kent
   mean resultant within `±0.03`, and `E[x²]`/`E[y²]` match
   `varianceAt(0)`/`varianceAt(1)` within `±0.03`; every lane is a unit vector.
2. **β=0 parity** — `VectorKent` with `β = 0` produces bit-for-bit identical
   samples to `VectorVonMisesFisher` for the same seed.
3. **f32x8, fills, and errors** — bulk fills produce unit lanes, and invalid
   κ/β or non-unit mean directions return the expected errors.

## Validation

- Focused `VectorKent` tests pass 3/3.
- `zig build apicheck` and `zig build distcheck` pass.
- `zig build test --summary all` passes 876/876 tests with all documentation
  gates.
- `docs/api-reference.md` updated for all 22 new public symbols.
- `compare/results/core-rand-coverage.md` S4-M1317 row added.

## Next bar

Vector Kent docs/distcheck/benchmark integration, vector-directional squeeze
optimizations, or newly discovered core gaps.
