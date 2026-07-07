# S4-M675 IndexVec Value Mapping Empty-Type Prevalidation

## Gap

`seq` owned/caller-owned/fixed value samples now reject non-zero uninhabited value
types before sampling. `IndexVec` value-mapping helpers could still allocate an
owned value slice or copy through indexes for empty enum-containing value types.

`IndexVec` value mappings should reject non-empty empty enum-containing value
types before owned allocation and before value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes indexed samples that are commonly mapped
back to slice values. Rust slices cannot contain safe values of empty enum types,
so comparable invalid value-type states are ruled out before mapping. Alea's
Zig-native `IndexVec` mappings can name empty enum-containing value types, so the
seq-style invalid input result is `error.EmptyInput` before allocation/copying.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `IndexVec.valuesChecked`
- `IndexVec.valuesInto`
- `IndexVec.valuesOwned`

`valuesIntoChecked` and `valuesOwnedChecked` inherit the behavior. The public
signatures are unchanged.

Deterministic behavior is explicit:

- Empty index vectors still map to empty outputs before validating the value
  type.
- Non-empty empty enum-containing value types return `error.EmptyInput` before
  owned allocation or value copying.
- Pointer mappings are unchanged because they only return addresses into caller
  slices.
- Habitable value types keep existing mapping behavior.

## Adoption and Documentation

- Focused seq tests cover `valuesChecked`, `valuesInto`, `valuesIntoChecked`,
  `valuesOwned`, and `valuesOwnedChecked` empty-enum failures with failing
  allocators where relevant, plus existing empty-index and normal mapping
  behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "index vec maps sampled indexes to slice items"
1/1 seq.test.index vec maps sampled indexes to slice items...OK
All 1 tests passed.
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M675 is closed for the current bar: `IndexVec` value mapping helpers now
reject non-empty empty enum-containing value types before owned allocation, value
copying, or assertions. This is reliability and ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
