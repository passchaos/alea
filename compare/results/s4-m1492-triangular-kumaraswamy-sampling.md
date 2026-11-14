# S4-M1492 Triangular and Kumaraswamy Extreme-Parameter Sampling

Date: 2026-11-14

## Change

Two samplers still overflowed at extreme parameters:

- `Triangular` sampled with `min + √(u·(max−min)·(mode−min))`, so ranges
  above about `1.3e154` overflowed the product and returned `±inf`
  (`Triangular(0, 5e299, 1e300)` produced `-inf`/`inf`). The scalar
  `triangularFrom`, the `Triangular.sample` facade, the vector kernel, and the
  bulk `triangularFromUniformsVector` fill now detect the overflow from the
  parameters alone and use `min + (max−min)·√(u·((mode−min)/(max−min)))`.
  The check depends only on `min`/`mode`/`max`, so the compiler unswitches it
  and the normal-range loop keeps its vectorized, stream-identical form.
- `Kumaraswamy` sampled `(1 − (1−u)^(1/β))^(1/α)`; for huge `β` the inner
  subtraction rounds to zero, `log(0)` becomes `-inf`, and
  `Kumaraswamy(1e300, 1e300)` returned 0 instead of the point mass at 1.
  The scalar and vector kernels now recover the tiny complement with
  `-expm1(-e/β)` when the direct difference is zero. The normal path keeps the
  exact original expressions.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `Triangular(0, 5e299, 1e300).sample` | −inf / inf | 2.7e299 … 7.4e299 | inside `[0, 1e300]` |
| `VectorTriangular(0, 5e299, 1e300).sample` | inf | 3.2e299 … 5.7e299 | inside `[0, 1e300]` |
| `fillTriangular` at the same range | inf | inside `[0, 1e300]` | — |
| `Kumaraswamy(1e300, 1e300).sample` | 0 | 1 | point mass at 1 |
| `VectorKumaraswamy(1e300, 1e300).sample` | 0 | 1 | point mass at 1 |

## Stream and Performance Check

A/B benchmark runs with the change stashed and restored:

- `alea triangular` 953.1M → 1023.0M samples/s, checksum `350566.296`
  unchanged;
- `alea triangular direct` 1046.5M → 1043.7M, checksum `348638.486`
  unchanged;
- `alea fillTriangular` 765.8M → 764.9M, checksum `350566.296` unchanged;
- `alea fillTriangular scalar direct` 794.5M → 793.4M, checksum `348638.486`
  unchanged;
- `alea kumaraswamy` 143.5M → 147.6M, checksum `387662.767` unchanged;
  `fillKumaraswamy` and its direct row keep `387194.553`/`387519.176`.

The parameter-only overflow branch preserves both throughput and the sampled
streams for normal parameters.

## Validation

- `zig build test --summary all` passes 925/925 (native `alea-tests` 906/906).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
