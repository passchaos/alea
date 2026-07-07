# S4-M720 Distribution Choose Checked Pointer Aliases

## Gap

Distribution-layer `Choose` has pointer fills, owned pointers, fixed pointer
arrays, and pointer iterators. It still lacked `Checked` aliases for pointer
output shapes, making pointer APIs less discoverable than the checked index and
value families.

Distribution-layer `Choose` should provide checked pointer aliases that preserve
stream shape while improving API consistency.

## Local `rand` Baseline

The local Rust `rand` checkout exposes reference-oriented choice workflows.
Alea's Zig-native API commonly provides checked aliases across output shapes;
distribution-layer `Choose` now matches that discoverability pattern for pointer
outputs.

## API Added

`src/distributions.zig` adds checked pointer aliases to `Choose(T)`:

- `Choose(T).fillChecked`
- `Choose(T).fillCheckedFrom`
- `Choose(T).ptrsChecked`
- `Choose(T).ptrsCheckedFrom`
- `Choose(T).ptrArrayChecked`
- `Choose(T).ptrArrayCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked pointer aliases preserve the stream shape of their existing pointer
  counterparts.
- Owned/fixed/caller-owned checked aliases are available for repeated pointer
  output.

## Adoption and Documentation

- Focused distribution tests compare checked pointer fill, owned pointer output,
  and fixed pointer arrays against their unchecked counterparts and confirm
  identical stream shape.
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M720 is closed for the current bar: distribution-layer `Choose` now has
checked aliases for caller-owned, owned, and fixed-size pointer outputs. This is
ergonomics/discoverability work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
