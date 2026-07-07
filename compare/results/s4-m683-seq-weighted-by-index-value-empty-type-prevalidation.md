# S4-M683 Seq Index-Weighted Value Choice Empty-Type Prevalidation

## Gap

Parallel-weight and item-accessor weighted value choices now reject non-zero
uninhabited value types before sampling. Index-weighted value choice helpers
could still validate index weights, allocate output buffers, or sample weighted
indexes before reaching impossible value-copying paths for empty enum-containing
value types.

`seq` index-weighted value choice helpers should reject non-zero empty
enum-containing value types before index-weight validation, weighted-index
sampling, allocation, random-stream use, and value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes index-weighted choice workflows where
impossible value types are ruled out by the type system before sampling. Alea's
Zig-native index-weighted value choice helpers can name empty enum-containing
value types, so `error.EmptyInput` is the deterministic pre-sampling validation
path.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in
index-weighted value-choice paths:

- `chooseWeightedByIndexFrom`
- `chooseWeightedByIndexCheckedFrom`
- `fillChooseWeightedByIndexFrom`
- `fillChooseWeightedByIndexCheckedFrom`
- `chooseWeightedValueArrayByIndexFrom`
- `chooseWeightedValueArrayByIndexCheckedFrom`
- `chooseWeightedBatchByIndexFrom`
- `chooseWeightedBatchByIndexCheckedFrom`

Pointer index-weighted helpers are unchanged because they only return addresses
into caller slices. The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  index-weight validation, allocation, weighted-index sampling, random-stream
  use, or value copying.
- Habitable value types keep existing index-weighted choice behavior and stream
  shape.

## Adoption and Documentation

- Focused seq tests cover scalar, fill, array, and batch index-weighted value
  choice failures for an empty enum value type, including failing allocator
  checks where relevant and zero random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "index-weighted chooseWeightedByIndex preserves stream shape and invalid paths do not consume"
1/2 seq.test.index-weighted chooseWeightedByIndex preserves stream shape and invalid paths do not consume...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "index-weighted chooseWeightedBatchByIndex allocates choice batches"
1/2 seq.test.index-weighted chooseWeightedBatchByIndex allocates choice batches...OK
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
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M683 is closed for the current bar: `seq` index-weighted value choice helpers
now reject non-zero empty enum-containing value types before index-weight
validation, allocation, weighted-index sampling, random-stream use, value copying,
or assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
