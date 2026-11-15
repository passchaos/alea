# S4-M1721 Poisson Ahrens-Dieter CDF Fill

Date: 2026-11-16

## Change

The scalar `Poisson.fill`/`fillFrom` Ahrens-Dieter branch drew every element
with the AD kernel. For `lambda <= 24`, where the 64-entry small CDF table
covers the distribution to about `1e-15`, the fill now builds the table once
and draws with one uniform plus a binary search; uniforms above the last
stored cumulative value fall back to the exact AD kernel. Larger lambdas keep
the per-element AD kernel. `sample` is unchanged.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillPoisson` (lambda=20, AD) | 86.6 M samples/s | 229.3 M samples/s | 2.6x |
| `alea fillPoisson scalar direct` | 131.0 M samples/s | 275.8 M samples/s | 2.1x |
| `alea fillPoisson small` (lambda=4) | ~270 M samples/s | ~255 M samples/s | unchanged/noise |

The checksums change because the AD fill stream is versioned (`5243298` ->
`5242975` facade, `5244357` -> `5245503` direct).

## Distribution Audit

A 100k-sample histogram of `fillPoisson(20)` has mean `20.004` and the
expected Poisson shape (bins `0-4: 2`, `5-9: 511`, `10-14: 9979`,
`15-19: 36639`, `20-24: 37055`, `25-29: 13602`, `30-34: 2064`,
`35-39: 140`, `40+: 8`). `tools/distcheck.zig` now gates
`fillPoisson(20)` CDF at `15`, `20`, and `25` over 800k samples, and
`distcheck -- --long 10000000` passes.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `src/distributions.zig`: the AD CDF fill branch and `poissonAdCdfFrom`.
- `tools/distcheck.zig`: `fillPoisson(20)` CDF gates.
- `compare/results/reproducibility-matrix.md`: records the versioned bulk
  fill stream.
