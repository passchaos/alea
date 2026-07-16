# S4-M1222 Static Multivariate Normal

Date: 2026-07-16

## Goal

Provide a Zig-native multivariate-normal shape for simulation kernels whose
dimension is known at compile time. The dynamic `MultivariateNormal(T)` remains
appropriate for runtime configuration, but it owns heap slices and uses
runtime dimensions for larger transforms.

## Implementation

`StaticMultivariateNormal(T, dimension)`:

- stores `[dimension]T` mean and `[dimension][dimension]T` Cholesky factor
  values inline;
- uses the same finite/symmetric/positive-semidefinite validation and
  factorization helper as dynamic `MultivariateNormal(T)`;
- requires no allocator and has no `deinit`;
- returns fixed `[dimension]T` samples and fills `[][dimension]T` batches;
- supports positive-definite, singular, and deterministic covariance;
- exposes dimension/rank/degeneracy, mean/factor, variance, covariance, and
  fixed covariance-matrix diagnostics; and
- is discoverable as `multi.StaticMultivariateNormal`.

Comptime dimensions allow Zig to unroll the standard-normal generation and
reverse lower-triangular transform.

## Performance

ReleaseFast/native real-harness 8D rows at the 1GiB benchmark count:

```text
alea multivariate-normal f64x8 direct: 31.9 M vectors/s checksum=4473.057
alea static multivariate-normal f64x8 direct: 46.0 M vectors/s checksum=4473.057
```

The static shape is about 44% faster on this host while preserving output and
final RNG state.

## Validation

Focused tests cover:

- exact output/state parity with the dynamic sampler;
- facade/direct single sampling and direct fixed-array batches;
- dynamic/static covariance diagnostics;
- singular and rank-zero no-consume behavior;
- invalid covariance rejection; and
- deterministic 8D mean/variance/covariance smoke gates.

`distcheck` independently checks static 3D means and all covariance entries.
The multivariate example demonstrates fixed-array single and batch sampling,
and cross-target validation keeps the inline-array type portable.

Commands run:

```text
$ zig test src/distributions.zig -OReleaseFast --test-filter 'multivariate normal'
All 10 tests passed.

$ zig build -Doptimize=ReleaseFast distcheck --summary all
distcheck ok

$ zig build crosscheck --summary all
Build Summary: 7/7 steps succeeded

$ zig build -Doptimize=ReleaseFast statcheck --summary all
statcheck ok

$ zig build validate-local --summary all
Build Summary: 114/114 steps succeeded; 602/602 tests passed

$ git diff --check
```

## Scope

This closes S4-M1222's allocation-free/comptime multivariate ergonomics and
performance bar. S4-M1223 remains open for broader platform execution, longer
validation, exact/default dense SIMD research, or newly discovered core
random-workflow gaps.
