# S4-M1495 Rice and Inverse-Gaussian Huge-Scale Sampling

Date: 2026-11-14

## Change

Two samplers still overflowed at extreme scales:

- `Rice` computed `sqrt(x² + y²)` from two Gaussian components with standard
  deviation `sigma`; at `sigma = 1e300` the squared sum overflows and the
  sample is `inf`. The kernel now checks the squared sum and falls back to
  `std.math.hypot(x, y)`, which keeps the magnitude finite.
- `InverseGaussian` evaluated the Michael–Schucany–Haas root
  `sqrt(4·shape·y + y²)` and `mean²/x`; at `mean = shape = 1e300` the root and
  the square overflow, producing `-inf` and then `NaN`. The sampler now takes
  a parameter-only guard: when `mean` or `shape` exceeds
  `sqrt(floatMax)/1600` (so `4·shape·y + y²` can overflow for practical
  normal draws), a cold `noinline` path uses `sqrt(y)·sqrt(4·shape + y)` and
  `mean·(mean/x)`. Below the threshold the original expressions run
  unchanged, so normal-parameter streams and codegen are preserved.

The guard lives in the scalar free function, the `InverseGaussian` methods,
the fill dispatcher (before the vector kernels), and the vector-lane kernel;
each cold path is a separate `noinline` helper, which keeps the hot vector
loops byte-identical (the first attempt inlined the helpers into the scalar
tail and cost the fill rows about 36%).

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `Rice(1e300, 1e300).sample` | inf | 1.84e300 | Rician magnitude |
| `InverseGaussian(1e300, 1e300).sample` | NaN | 7.27e299 | mean 1e300 |
| `inverseGaussianFrom(1e300, 1)` | NaN | finite | mean scale |
| `inverseGaussianFrom(1, 1e300)` | NaN | finite | mean scale |
| `fillInverseGaussian` at 1e300 | NaN | finite | — |

## Stream and Performance Check

A/B benchmark runs with the change stashed and restored:

- `alea inverse-gaussian` 576.8M → 571.9M, checksum `1048292.502`;
- `alea inverse-gaussian fast direct` 549.8M → 545.0M, same checksum;
- `alea fillInverseGaussian` 428.2M → 436.8M, checksum `1049168.644`;
- `alea fillInverseGaussian scalar direct` 449.5M → 446.7M, checksum
  `1048444.479`;
- `alea inverse-gaussian cached` 591.0M → 588.3M, checksum `1048180.566`;
- the normal-inverse-gaussian rows keep `604425.701`/`605409.233`/
  `605605.274`/`605041.911` and their throughput.

All rows stay within noise with identical checksums. Rice has no benchmark
row.

## Validation

- `zig build test --summary all` passes 927/927 (native `alea-tests` 908/908).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
