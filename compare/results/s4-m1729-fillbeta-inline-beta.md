# S4-M1729 Fill Beta Through The Inline Kernel

Date: 2026-11-16

## Change

`fillBeta`'s general path constructed a `Beta(T)` sampler per call and called
its `fill`, which loops the cached gamma samplers. It now loops
`beta(rng, T, alpha, beta_param)` directly, which uses the S4-M1724 inline
gamma kernel with the same association order and special-case dispatch. The
special-case and Cheng paths stay as they were; `fillBetaFrom` is unchanged.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"fillBeta"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillBeta` | 123.7 M samples/s | 135.8-136.2 M samples/s | +10% |
| `alea fillBeta scalar direct` | 79.6 M samples/s | 79.4-79.7 M samples/s | unchanged |

The checksum is unchanged (`37447.095`), confirming the same stream.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `src/distributions.zig`: the `fillBeta` general-path loop.
- `compare/results/reproducibility-matrix.md`: records the stream-preserving
  speedup.
