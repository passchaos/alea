# S4-M729 Choice Checked Pointer Aliases

## Gap

Distribution-layer `Choose` has checked pointer aliases for caller-owned fills,
owned pointer batches, and fixed pointer arrays. Reusable `Choice` now has
explicit pointer iterator aliases, but its pointer fill/owned/fixed-array output
families still lacked matching checked aliases.

Reusable `Choice` should provide checked pointer aliases that preserve stream
shape while improving API consistency across pointer output shapes.

## Local `rand` Baseline

The local Rust `rand` checkout exposes reference-oriented choice workflows.
Alea's reusable `Choice(T)` already provides pointer outputs for repeated
reference sampling; checked pointer aliases make those reference-oriented paths
more discoverable while preserving Zig-native pointer/value/index output
families.

## API Added

`src/seq.zig` adds checked pointer aliases to `Choice(T)`:

- `Choice(T).fillChecked`
- `Choice(T).fillCheckedFrom`
- `Choice(T).ptrsChecked`
- `Choice(T).ptrsCheckedFrom`
- `Choice(T).ptrArrayChecked`
- `Choice(T).ptrArrayCheckedFrom`

The aliases delegate to existing pointer output behavior. `docs/api-reference.md`
lists the new public symbols. Existing APIs are unchanged.

Deterministic behavior is explicit:

- Checked pointer aliases preserve the stream shape of their existing pointer
  counterparts.
- Owned/fixed/caller-owned checked aliases are available for repeated pointer
  output.
- Checked pointer aliases do not introduce new failure modes because non-empty
  `Choice` construction already validates the item slice.

## Adoption and Documentation

- Focused seq tests compare checked pointer fill, owned pointer output, and fixed
  pointer arrays against their unchecked counterparts and confirm identical
  stream shape.
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
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M729 is closed for the current bar: reusable `Choice` now has checked aliases
for caller-owned, owned, and fixed-size pointer outputs. This is
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
