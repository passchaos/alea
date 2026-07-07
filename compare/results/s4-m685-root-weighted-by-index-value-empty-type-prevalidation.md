# S4-M685 Root Index-Weighted Value Choice Empty-Type Prevalidation

## Gap

`seq` index-weighted value choices now reject non-zero uninhabited value types
before index-weight validation and sampling. Root index-weighted value choice
helpers could still validate index weights, allocate output buffers, request
entropy, or copy impossible values for empty enum-containing value types.

Root index-weighted value choice helpers should reject non-zero empty
enum-containing value types before index-weight validation, allocation, entropy,
secure-engine construction, and value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes index-weighted choice workflows where
impossible value types are ruled out by the type system before sampling. Alea's
Zig-native root index-weighted value helpers can name empty enum-containing value
types, so `error.EmptyRange` is the deterministic pre-sampling validation path at
the root API layer.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in
index-weighted value-choice paths:

- `chooseWeightedByIndex`
- `chooseWeightedByIndexChecked`
- `fillChooseWeightedByIndex`
- `fillChooseWeightedByIndexChecked`
- `chooseWeightedValueArrayByIndex`
- `chooseWeightedValueArrayByIndexChecked`
- `chooseWeightedBatchByIndex`
- `chooseWeightedBatchByIndexChecked`

Pointer index-weighted helpers are unchanged because they only return addresses
into caller slices. The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  index-weight validation, allocation, entropy, secure-engine construction, or
  value copying.
- Habitable value types keep existing index-weighted root behavior and stream
  shape.

## Adoption and Documentation

- Focused root tests cover scalar, fill, array, and batch index-weighted value
  choice failures for an empty enum value type, including failing allocator
  checks where relevant and no entropy request.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
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
toolingcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M685 is closed for the current bar: root index-weighted value choice helpers
now reject non-zero empty enum-containing value types before index-weight
validation, allocation, entropy, secure-engine construction, value copying, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
