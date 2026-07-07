# S4-M702 Seq Weighted Choice Iterator Empty-Type Prevalidation

## Gap

`seq` weighted iterator one-shot choices now reject empty enum-containing output
types before consuming weighted iterators. Reusable weighted choice iterator
constructors (`chooseWeightedIter*`) could still validate/evaluate weights or
allocate alias-table state before producing iterators for uninhabited value types.

`seq.chooseWeightedIter*` should reject non-empty uninhabited value types before
weight validation/evaluation, allocation, random-stream use, iterator
construction, or value access.

## Local `rand` Baseline

The local Rust `rand` checkout exposes reusable weighted choice workflows that
return references over inhabited slice items. Rust's normal type flow avoids
constructing impossible output values, while Alea's reusable weighted choice
iterators can name empty enum-containing value types.

For Alea, seq-style reusable weighted value iterators return `error.EmptyInput`
for non-empty uninhabited value types before allocating alias tables or invoking
weight accessors.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseWeightedIterFrom`
- `chooseWeightedIterByFrom`
- `chooseWeightedIterByIndexFrom`

Checked variants inherit this behavior:
`chooseWeightedIterCheckedFrom`, `chooseWeightedIterByCheckedFrom`, and
`chooseWeightedIterByIndexCheckedFrom`.

Public signatures are unchanged.

Deterministic behavior is explicit:

- Empty/no-positive weighted inputs of habitable value types still return `null`
  / `error.EmptyInput` without random-stream use.
- Non-empty empty enum-containing value types return `error.EmptyInput` before
  weight validation/evaluation, alias-table allocation, random-stream use,
  iterator construction, or value access.
- Pointer/value reference semantics for habitable item types remain unchanged.

## Adoption and Documentation

- Focused seq tests cover parallel-weight, item-accessor, and index-accessor
  reusable weighted choice iterator constructors for a regular struct containing
  an empty enum field. Tests use failing allocators and `unreachable` accessors
  to prove preallocation and pre-evaluation behavior.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice iterator streams repeated const pointers"
1/4 seq.test.weighted choice iterator streams repeated const pointers...OK
2/4 seq.test.accessor weighted choice iterator streams repeated const pointers...OK
3/4 seq.test.index-weighted choice iterator streams repeated const pointers...OK
4/4 root.test_0...OK
All 4 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "accessor weighted choice iterator streams repeated const pointers"
1/2 seq.test.accessor weighted choice iterator streams repeated const pointers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "index-weighted choice iterator streams repeated const pointers"
1/2 seq.test.index-weighted choice iterator streams repeated const pointers...OK
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
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M702 is closed for the current bar: `seq` reusable weighted choice iterator
constructors now reject non-empty empty enum-containing value types before
accessor evaluation, allocation, random-stream use, iterator construction, value
access, or assertions. This is reliability and ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
