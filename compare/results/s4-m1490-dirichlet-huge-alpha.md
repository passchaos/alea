# S4-M1490 Dirichlet Huge-Alpha Sampling

Date: 2026-11-14

## Change

`Dirichlet.sampleInto`/`sampleIntoFrom` accumulated the gamma draws and
divided by their total. For alpha vectors near `1e308` the total overflows
f64, so every weight divided by `inf` and the sampler returned all zeros
(`Dirichlet{1e308, 1e308}` produced `(0, 0)`).

The new `normalizeGammaDraws` helper keeps the existing loop and division
unchanged when the total is finite (so the stream and all benchmark
checksums are untouched) and, for a non-finite total, rescales the draws by
the largest draw before normalizing. `Dirichlet{1e308, 1e308}` now samples
`(0.5, 0.5)` with a unit sum, and the `1e300`/`3e300` case still returns
`(0.25, 0.75)` through the unchanged finite path.

`WeightedAliasIndex`, `WeightedTreeIndex`, and `WeightedIndex` were also
probed with `1e308` weights; they already reject the overflowing total with
`error.InvalidWeight`, so no change was needed there.

## Before/After

| call | before | after | reference |
| --- | --- | --- | --- |
| `Dirichlet{1e308, 1e308}.sampleInto` | (0, 0) | (0.5, 0.5) | alpha weights, unit sum |
| `Dirichlet{1e300, 3e300}.sampleInto` | (0.25, 0.75) | (0.25, 0.75) | finite total |
| `WeightedAliasIndex({1e308, 1e308})` | `error.InvalidWeight` | `error.InvalidWeight` | explicit rejection |

The finite-total normalization path is byte-identical, so no RNG stream
changed for normal parameters.

## Validation

- `zig build test --summary all` passes 924/924 (native `alea-tests` 905/905).
- `zig build statcheck` and `zig build distcheck` pass.
- `zig build roadmapcheck` and the doc checks pass.

The aggregate `validate-all` refresh is tracked as the following milestone.
