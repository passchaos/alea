# S4-M739 AliasTable Checked Iterators

## Gap

Reusable `WeightedChoice`, distribution-layer `Choose`, and dynamic weighted
samplers now expose checked iterator aliases for their index iterator families.
Static `AliasTable` still exposed only unchecked `iter*` / `iterU32*` names,
leaving static weighted-index iterator workflows less discoverable and less
consistent with the rest of the weighted sampler surface.

`AliasTable` should provide checked iterator aliases that preserve existing
stream shape and compact `u32` width validation.

## Local `rand` Baseline

The local Rust `rand` / `rand_distr` weighted-index workflows expose reusable
weighted index sampling. Alea's `AliasTable(Weight)` already provides reusable
iterator helpers for repeated `usize` and compact `u32` weighted indexes;
checked aliases make those paths explicit and align naming with higher-level
Zig-native samplers.

## API Added

`src/distributions.zig` adds checked iterator aliases to `AliasTable(Weight)`:

- `AliasTable(Weight).iterChecked`
- `AliasTable(Weight).iterCheckedFrom`
- `AliasTable(Weight).iterU32Checked`
- `AliasTable(Weight).iterU32CheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked `usize` iterator aliases preserve `iterFrom` stream shape.
- Checked compact `u32` iterator aliases preserve `iterU32From` stream shape.
- Checked compact aliases preserve existing `error.InvalidParameter` behavior
  when the alias table length does not fit `u32`.

## Adoption and Documentation

- Focused `AliasTable` tests compare checked and unchecked `usize` and compact
  `u32` iterator scalar draws for stream parity.
- Existing iterator tests continue to cover fill behavior and single-positive
  no-consumption paths.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
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
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M739 is closed for the current bar: static `AliasTable` now has checked
iterator aliases for `usize` and compact `u32` index iterators. This is
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
