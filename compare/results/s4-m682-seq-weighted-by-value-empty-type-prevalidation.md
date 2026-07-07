# S4-M682 Seq Accessor-Weighted Value Choice Empty-Type Prevalidation

## Gap

Parallel-weight value choices now reject non-zero uninhabited value types before
sampling. Item-accessor weighted value choice helpers could still call accessor
functions, validate weights, allocate output buffers, or sample weighted indexes
before reaching impossible value-copying paths for empty enum-containing value
types.

`seq` item-accessor weighted value choice helpers should reject non-zero
uninhabited value types before accessor weight evaluation, weighted-index
sampling, allocation, random-stream use, and value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes accessor/closure-weighted choice workflows
where impossible value types are ruled out by the type system before sampling.
Alea's Zig-native accessor-weighted value choice helpers can name value types
containing empty enum fields, so `error.EmptyInput` is the deterministic
pre-sampling validation path.

## API Changed

`src/seq.zig` now prevalidates uninhabited value types in item-accessor weighted
value-choice paths:

- `chooseWeightedByFrom`
- `chooseWeightedByCheckedFrom`
- `fillChooseWeightedByFrom`
- `fillChooseWeightedByCheckedFrom`
- `chooseWeightedValueArrayByFrom`
- `chooseWeightedValueArrayByCheckedFrom`
- `chooseWeightedBatchByFrom`
- `chooseWeightedBatchByCheckedFrom`

The shared `valueTypeHasEmptyEnum` helper now catches empty enum fields in
regular structs as well as tuples and arrays. Pointer accessor-weighted helpers
are unchanged because they only return addresses into caller slices. The public
signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero uninhabited value types return `error.EmptyInput` before accessor
  calls, allocation, weighted-index sampling, random-stream use, or value
  copying.
- Habitable value types keep existing accessor-weighted choice behavior and
  stream shape.

## Adoption and Documentation

- Focused seq tests cover scalar, fill, array, and batch accessor-weighted value
  choice failures for a value type containing an empty enum field, including
  failing allocator checks where relevant and zero random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "chooseWeightedBy preserves facade/direct stream shape and invalid paths do not consume"
1/2 seq.test.chooseWeightedBy preserves facade/direct stream shape and invalid paths do not consume...OK
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
examplecheck ok
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M682 is closed for the current bar: `seq` item-accessor weighted value choice
helpers now reject non-zero uninhabited value types before accessor weight
evaluation, allocation, weighted-index sampling, random-stream use, value
copying, or assertions. This is reliability and ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
