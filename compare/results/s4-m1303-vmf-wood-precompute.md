# S4-M1303 — Precomputed Wood constants for reusable vMF sampling

## Goal

Raise `VonMisesFisher(T, n)` throughput without changing its output. The
S4-M1301 benchmark recorded 21.1 M samples/s for `alea von mises-fisher 3d`;
every sample rebuilt Wood's rejection constants (`b`, `x0`, `c`) from κ even
though κ is fixed for a reusable sampler.

## Changes

### Precomputed constants

- `VonMisesFisher(T, n)` now stores `wood_b`, `wood_x0`, and `wood_c` for
  `n ≥ 3` when `0 < κ ≤ 1e12`. They are computed once in `init` /
  `initNormalized` and reused by every `sample`, `sampleFrom`, `fill`, and
  `fillFrom` call.
- `n == 2` keeps the exact Von Mises angle path; `κ = 0` and `κ > 1e12` keep
  their uniform and point-mass fast paths.

### Shared helpers

- `vmfSampleWFrom` now delegates its rejection loop to
  `vmfSampleWWithConstantsFrom`, so the free-function and reusable-sampler
  paths share one implementation.
- The post-`w` assembly (uniform tangent point, e₁-frame assembly, Householder
  reflection) is factored into `vonMisesFisherFromW`, used by both paths.

The draw order and arithmetic are unchanged: the optimized type and the free
function produce bit-for-bit identical samples, and the benchmark checksum is
unchanged.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "von mises-fisher"`

| Revision | M samples/s | Checksum |
| --- | ---: | ---: |
| S4-M1301 per-sample constants | 21.1 | 8599378168322326816 |
| S4-M1303 precomputed constants | 43.1 | 8599378168322326816 |

The reusable sampler is 2.04× faster with identical output.

## Validation

- `zig test src/root.zig --test-filter "VonMisesFisher"` passes 11/11,
  including a new bit-for-bit parity test between the type and the free
  function for 3D and 4D.
- `zig build test --summary all` passes 853/853 tests with all documentation
  gates.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `compare/results/core-rand-coverage.md` S4-M1303 row added.

## Next bar

Apply the same constant-precomputation pattern to Watson, Matrix von
Mises-Fisher, vector/SIMD copula/Bingham/Kent sampling, or newly discovered
core gaps against local Rust `rand` / `rand_distr` evidence.
