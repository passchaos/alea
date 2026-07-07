# S4-M712 Distribution Choose U32 Index Outputs

## Gap

Distribution-layer `Choose` now has usize index outputs. It still lacked compact
`u32` index output helpers, which are useful for large repeated output buffers
when the item set fits in a 32-bit index.

Distribution-layer `Choose` should expose compact u32 index outputs matching its
usize index stream policy and existing `Rng.chooseIndexU32*` style.

## Local `rand` Baseline

The local Rust `rand` checkout exposes index-oriented slice sampling utilities in
addition to reference choices. Alea already exposes compact u32 index choices in
`Rng` and `seq`; distribution-layer `Choose(T)` can provide the same compact
output shape for sampler-centric workflows.

## API Added

`src/distributions.zig` adds u32 index helpers to `Choose(T)`:

- `Choose(T).sampleIndexU32`
- `Choose(T).sampleIndexU32From`
- `Choose(T).fillIndicesU32`
- `Choose(T).fillIndicesU32From`
- `Choose(T).indicesU32`
- `Choose(T).indicesU32From`
- `Choose(T).indexArrayU32`
- `Choose(T).indexArrayU32From`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- u32 index outputs use the same stream shape as equivalent usize/Rng compact
  index choices over the sampler's item length.
- Singleton choices fill compact index outputs with zero without random-stream
  use.
- Oversized item sets return `error.InvalidParameter` for u32 helpers.
- Owned/fixed/caller-owned shapes are available for repeated compact index
  output.

## Adoption and Documentation

- Focused distribution tests compare scalar u32 index choice with
  `Rng.chooseIndexU32`, fixed u32 index arrays against u32 index fills, and owned
  u32 index output against u32 index fills. Singleton no-consumption behavior is
  also covered.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

No output.

Broader native test gate:

```text
$ zig build test
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M712 is closed for the current bar: distribution-layer `Choose` now has
scalar, caller-owned, owned, and fixed-size u32 index outputs aligned with its
item sampling stream shape. This is ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
