# S4-M731 Choice Checked Index Aliases

## Gap

Distribution-layer `Choose` exposes checked aliases for scalar, caller-owned,
owned, fixed-array, and iterator `usize` index output shapes. Reusable `Choice`
only exposed the unchecked `usize` index names while its `u32` fixed-array path
already had checked aliases, leaving reusable unweighted index APIs less
consistent and less discoverable.

Reusable `Choice` should provide checked `usize` index aliases that preserve
stream shape while improving API consistency across index output shapes.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice workflows centered on
reference/index selection. Alea's reusable `Choice(T)` already provides scalar,
caller-owned, owned, fixed-array, and iterator index outputs; checked aliases make
those index-oriented paths more discoverable while preserving Zig-native
pointer/value/index output families.

## API Added

`src/seq.zig` adds checked `usize` index aliases to `Choice(T)`:

- `Choice(T).sampleIndexChecked`
- `Choice(T).sampleIndexCheckedFrom`
- `Choice(T).fillIndicesChecked`
- `Choice(T).fillIndicesCheckedFrom`
- `Choice(T).indicesChecked`
- `Choice(T).indicesCheckedFrom`
- `Choice(T).indexArrayChecked`
- `Choice(T).indexArrayCheckedFrom`
- `Choice(T).indexIterChecked`
- `Choice(T).indexIterCheckedFrom`

The aliases delegate to existing `usize` index output behavior.
`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked `usize` index aliases preserve the stream shape of their existing index
  counterparts.
- Scalar/caller-owned/owned/fixed/iterator checked aliases are available for
  repeated index output.
- Checked `usize` aliases do not introduce new failure modes because non-empty
  `Choice` construction already validates the item slice and `usize` indexes do
  not need width checks.

## Adoption and Documentation

- Focused seq tests compare checked scalar indexes, caller-owned fills, owned
  batches, fixed arrays, and iterators against their unchecked counterparts and
  confirm identical stream shape.
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
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M731 is closed for the current bar: reusable `Choice` now has checked aliases
for scalar, caller-owned, owned, fixed-size, and iterator `usize` index outputs.
This is ergonomics/discoverability work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
