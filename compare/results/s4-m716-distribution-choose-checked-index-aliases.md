# S4-M716 Distribution Choose Checked Index Aliases

## Gap

Distribution-layer `Choose` has usize index outputs and u32 fallible outputs.
The usize index helpers cannot fail after construction, but Alea's public API
convention commonly offers checked aliases for discoverability and parity across
index-output families.

Distribution-layer `Choose` should provide checked usize index aliases that
preserve stream shape while improving API consistency.

## Local `rand` Baseline

The local Rust `rand` checkout exposes both direct and fallible construction
patterns around slice sampling. Alea's Zig-native API uses explicit checked
suffixes across many index and choice helpers; distribution-layer `Choose` now
matches that discoverability pattern.

## API Added

`src/distributions.zig` adds checked usize index aliases to `Choose(T)`:

- `Choose(T).sampleIndexChecked`
- `Choose(T).sampleIndexCheckedFrom`
- `Choose(T).fillIndicesChecked`
- `Choose(T).fillIndicesCheckedFrom`
- `Choose(T).indicesChecked`
- `Choose(T).indicesCheckedFrom`
- `Choose(T).indexArrayChecked`
- `Choose(T).indexArrayCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked aliases preserve the stream shape of their unchecked usize
  counterparts.
- Owned/fixed/caller-owned checked aliases are available for repeated usize index
  output.

## Adoption and Documentation

- Focused distribution tests compare checked scalar, fill, fixed-array, and owned
  index outputs against their unchecked counterparts and confirm identical stream
  shape.
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
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M716 is closed for the current bar: distribution-layer `Choose` now has
checked aliases for scalar, caller-owned, owned, and fixed-size usize index
outputs. This is ergonomics/discoverability work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
