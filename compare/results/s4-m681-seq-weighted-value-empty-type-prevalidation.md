# S4-M681 Seq Weighted Value Choice Empty-Type Prevalidation

## Gap

Weighted iterator value reservoirs now reject non-zero uninhabited value types
before sampling. Parallel-weight `seq` value choice helpers could still validate
weights, allocate output buffers, or sample weighted indexes before reaching
impossible value-copying paths for empty enum-containing value types.

`seq` weighted value choice helpers should reject non-zero empty enum-containing
value types before weighted-index sampling, allocation, random-stream use, and
value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted choice workflows where impossible
value types are ruled out by the type system before sampling. Alea's Zig-native
weighted value choice helpers can name empty enum-containing value types, so
`error.EmptyInput` is the deterministic pre-sampling validation path.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in weighted
value-choice paths:

- `chooseWeightedFrom`
- `chooseWeightedCheckedFrom`
- `fillChooseWeightedFrom`
- `fillChooseWeightedCheckedFrom`
- `chooseWeightedValueArrayFrom`
- `chooseWeightedValueArrayCheckedFrom`
- `chooseWeightedBatchFrom`
- `chooseWeightedBatchCheckedFrom`

Pointer weighted-choice helpers are unchanged because they only return addresses
into caller slices. The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  allocation, weighted-index sampling, random-stream use, or value copying.
- Habitable value types keep existing weighted choice behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover scalar, fill, array, and batch weighted value-choice
  empty-enum failures with failing allocators where relevant and zero
  random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "chooseWeighted selects values and mutable pointers"
1/2 seq.test.chooseWeighted selects values and mutable pointers...OK
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
toolingcheck ok
examplecheck ok
```

## Result

S4-M681 is closed for the current bar: `seq` weighted value choice helpers now
reject non-zero empty enum-containing value types before allocation,
weighted-index sampling, random-stream use, value copying, or assertions. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
