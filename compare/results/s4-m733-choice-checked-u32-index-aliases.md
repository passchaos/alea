# S4-M733 Choice Checked U32 Index Aliases

## Gap

Reusable `Choice` now has checked `usize` index aliases for scalar,
caller-owned, owned, fixed-array, and iterator output shapes. Its compact `u32`
index family still only exposed checked naming for fixed arrays, leaving scalar,
caller-owned, owned, and iterator compact index APIs less consistent with
`Choose`, weighted trees, and the reusable `usize` alias family.

Reusable `Choice` should provide checked compact `u32` index aliases that
preserve stream shape while improving API consistency across compact index output
shapes.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice workflows centered on
reference/index selection. Alea's reusable `Choice(T)` already provides compact
`u32` scalar, caller-owned, owned, fixed-array, and iterator index outputs for
populations that fit `u32`; checked aliases make those compact index paths more
discoverable while preserving Zig-native pointer/value/index output families.

## API Added

`src/seq.zig` adds checked compact `u32` index aliases to `Choice(T)`:

- `Choice(T).sampleIndexU32Checked`
- `Choice(T).sampleIndexU32CheckedFrom`
- `Choice(T).fillIndicesU32Checked`
- `Choice(T).fillIndicesU32CheckedFrom`
- `Choice(T).indicesU32Checked`
- `Choice(T).indicesU32CheckedFrom`
- `Choice(T).indexIterU32Checked`
- `Choice(T).indexIterU32CheckedFrom`

Existing fixed-array checked aliases remain unchanged:

- `Choice(T).indexArrayU32Checked`
- `Choice(T).indexArrayU32CheckedFrom`

The aliases delegate to existing compact `u32` index output behavior.
`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked compact `u32` index aliases preserve the stream shape of their existing
  compact index counterparts.
- Scalar/caller-owned/owned/fixed/iterator checked aliases are available for
  repeated compact index output.
- Checked compact aliases preserve existing `error.InvalidParameter` behavior
  when the population does not fit `u32`.

## Adoption and Documentation

- Focused seq tests compare checked scalar compact indexes, caller-owned fills,
  owned batches, and iterators against their unchecked counterparts and confirm
  identical stream shape.
- Existing fixed-array checked tests continue to cover `indexArrayU32Checked*`.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
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
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M733 is closed for the current bar: reusable `Choice` now has checked aliases
for scalar, caller-owned, owned, fixed-size, and iterator compact `u32` index
outputs. This is ergonomics/discoverability work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
