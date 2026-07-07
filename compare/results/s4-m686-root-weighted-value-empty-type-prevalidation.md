# S4-M686 Root Weighted Value Choice Empty-Type Prevalidation

## Gap

`seq` parallel-weight value choices now reject non-zero uninhabited value types
before sampling. Root parallel-weight value choice helpers could still validate
weights, allocate output buffers, request entropy, or copy impossible values for
empty enum-containing value types.

Root parallel-weight value choice helpers should reject non-zero empty
enum-containing value types before weighted-index sampling, allocation, entropy,
secure-engine construction, and value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted choice workflows where impossible
value types are ruled out by the type system before sampling. Alea's Zig-native
root weighted value helpers can name empty enum-containing value types, so
`error.EmptyRange` is the deterministic pre-sampling validation path at the root
API layer.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in
parallel-weight value-choice paths:

- `chooseWeighted`
- `chooseWeightedChecked`
- `fillChooseWeighted`
- `fillChooseWeightedChecked`
- `chooseWeightedValueArray`
- `chooseWeightedValueArrayChecked`
- `chooseWeightedBatch`
- `chooseWeightedBatchChecked`

Pointer weighted helpers are unchanged because they only return addresses into
caller slices. The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  weighted-index sampling, allocation, entropy, secure-engine construction, or
  value copying.
- Habitable value types keep existing weighted root behavior and stream shape.

## Adoption and Documentation

- Focused root tests cover scalar, fill, array, and batch parallel-weight value
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
apicheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M686 is closed for the current bar: root parallel-weight value choice helpers
now reject non-zero empty enum-containing value types before weighted-index
sampling, allocation, entropy, secure-engine construction, value copying, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
