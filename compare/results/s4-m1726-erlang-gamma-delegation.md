# S4-M1726 Erlang Gamma Delegation

Date: 2026-11-16

## Change

`erlang(rng, T, shape, scale)` constructed an `Erlang(T)` sampler (which
builds a cached `Gamma(T)`) on every call and then called its `sample`. It
now delegates to `gamma(rng, T, shape, scale)`, whose inline Marsaglia-Tsang
kernel (S4-M1724) uses the same association order and special paths. The
reusable `Erlang` sampler is unchanged.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"alea erlang"`, bracketed A/B:

| Configuration | Runs |
| --- | --- |
| `Erlang` sampler construction | 219.8, 216.8, 210.5 M samples/s |
| `gamma` delegation | 220.8, 220.8, 220.6 M samples/s |

The checksum is unchanged (`786282.458`), confirming the same stream. The
gain is small (about +1-5% against a drifting baseline) but the delegation
removes the per-call sampler construction and keeps the code simpler.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `src/distributions.zig`: the `erlang` free function delegates to `gamma`.
