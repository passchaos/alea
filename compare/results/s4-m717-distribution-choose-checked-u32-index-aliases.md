# S4-M717 Distribution Choose Checked U32 Index Aliases

## Gap

Distribution-layer `Choose` now has checked usize index aliases and fallible u32
index outputs. The u32 family still lacked explicit `Checked` aliases, making the
compact index API less discoverable than other Alea index helpers.

Distribution-layer `Choose` should provide checked u32 index aliases that
preserve stream shape while improving API consistency.

## Local `rand` Baseline

The local Rust `rand` checkout exposes direct/fallible patterns around indexed
sampling. Alea's Zig-native API consistently offers checked suffixes across many
compact-index helpers; distribution-layer `Choose` now matches that pattern.

## API Added

`src/distributions.zig` adds checked u32 index aliases to `Choose(T)`:

- `Choose(T).sampleIndexU32Checked`
- `Choose(T).sampleIndexU32CheckedFrom`
- `Choose(T).fillIndicesU32Checked`
- `Choose(T).fillIndicesU32CheckedFrom`
- `Choose(T).indicesU32Checked`
- `Choose(T).indicesU32CheckedFrom`
- `Choose(T).indexArrayU32Checked`
- `Choose(T).indexArrayU32CheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked aliases preserve the stream shape of their existing u32 counterparts.
- They retain the same oversized-item-set `error.InvalidParameter` behavior as
  the existing u32 helpers.
- Owned/fixed/caller-owned checked aliases are available for repeated u32 index
  output.

## Adoption and Documentation

- Focused distribution tests compare checked scalar, fill, fixed-array, and owned
  u32 index outputs against their existing u32 counterparts and confirm identical
  stream shape.
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
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M717 is closed for the current bar: distribution-layer `Choose` now has
checked aliases for scalar, caller-owned, owned, and fixed-size u32 index
outputs. This is ergonomics/discoverability work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
