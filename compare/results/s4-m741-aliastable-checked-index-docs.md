# S4-M741 AliasTable Checked Index Docs

## Gap

Static `AliasTable` already exposed checked `usize` index APIs such as
`sampleChecked*`, `fillChecked*`, `indicesChecked*`, and
`indexArrayChecked*`, but `docs/api-reference.md` only listed part of the checked
surface, mostly compact `u32` names and the newer checked iterator aliases.

This made static weighted-index checked APIs less discoverable than
`WeightedChoice`, dynamic trees, and distribution-layer `Choose`, even though the
symbols were public and already tested.

## Local `rand` Baseline

The local Rust `rand` / `rand_distr` weighted-index workflows expose reusable
weighted-index sampling as a prominent API. Alea's `AliasTable(Weight)` provides
checked variants for fallible/static weighted-index workflows; documenting the
full checked surface keeps Zig-native users from needing to infer symbol names.

## Documentation Updated

`docs/api-reference.md` now lists these existing public symbols for
`AliasTable(Weight)`:

- `AliasTable.sampleChecked`
- `AliasTable.sampleIndexChecked`
- `AliasTable.sampleCheckedFrom`
- `AliasTable.sampleIndexCheckedFrom`
- `AliasTable.fillChecked`
- `AliasTable.fillIndicesChecked`
- `AliasTable.fillCheckedFrom`
- `AliasTable.fillIndicesCheckedFrom`
- `AliasTable.indicesChecked`
- `AliasTable.indicesCheckedFrom`
- `AliasTable.indexArrayChecked`
- `AliasTable.indexArrayCheckedFrom`

No runtime behavior changed.

## Adoption and Documentation

- The public API reference now matches the existing checked `AliasTable` `usize`
  API surface.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

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
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M741 is closed for the current bar: static `AliasTable` checked `usize` index
APIs are documented alongside the rest of the checked weighted-index surface.
This is documentation/discoverability work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
