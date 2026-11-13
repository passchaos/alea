# S4-M1368 — Direct cosine/sine Kent conditional direction

## Goal

Return `(cos φ, sin φ)` directly from the Kent conditional-direction sampler
so the assembly never calls `acos`, `cos`, or `sin`.

## Implementation

- Added `kentConditionalCosSinFrom`:
  - for `a < 1.5`, a uniform circle proposal is accepted with the Exp(1) race
    `E >= 2a(1 − cos²φ)` (equivalent to `exp(a(cos 2φ − 1))`), and the accepted
    circle point is returned directly;
  - for `a ≥ 1.5`, `vonMises2dPointFrom(1, 0, a)` returns `(cos θ, sin θ)`
    without `acos`, and the half-angle identities give
    `cos(θ/2) = √((1+cos θ)/2)`, `sin(θ/2) = sign(sin θ)·√((1−cos θ)/2)`;
    the π flip negates both components.
- `kentPointFrom` uses the returned pair for the tangent assembly. The vector
  Kent path keeps the angle-based von Mises assembly.
- The sampled law is unchanged; only the RNG consumption and last-bit
  rounding differ.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea kent 3d` | 19.6M samples/s | 27.0M samples/s | +38% |
| `alea vector kent f64x4 3d` | 4.1M vectors/s | 4.1M vectors/s | unchanged |

The scalar checksum changes to `9761654497349534419` and is stable; the
vector Kent checksum is unchanged (`14944598552313217847`).

## Validation

- All 10 scalar/vector Kent tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further Kent or multivariate kernel tuning, or newly discovered core gaps.
