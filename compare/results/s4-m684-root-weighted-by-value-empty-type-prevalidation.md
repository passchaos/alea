# S4-M684 Root Accessor-Weighted Value Choice Empty-Type Prevalidation

## Gap

`seq` item-accessor weighted value choices now reject non-zero uninhabited value
types before accessor calls and sampling. Root item-accessor weighted value choice
helpers could still call accessor functions, allocate output buffers, request
entropy, or copy impossible values for types containing empty enum fields.

Root item-accessor weighted value choice helpers should reject non-zero
uninhabited value types before accessor weight evaluation, allocation, entropy,
secure-engine construction, and value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes accessor/closure-weighted choice workflows
where impossible value types are ruled out by the type system before sampling.
Alea's Zig-native root accessor-weighted value helpers can name value types
containing empty enum fields, so `error.EmptyRange` is the deterministic
pre-sampling validation path at the root API layer.

## API Changed

`src/root.zig` now prevalidates uninhabited value types in item-accessor weighted
value-choice paths:

- `chooseWeightedBy`
- `chooseWeightedByChecked`
- `fillChooseWeightedBy`
- `fillChooseWeightedByChecked`
- `chooseWeightedValueArrayBy`
- `chooseWeightedValueArrayByChecked`
- `chooseWeightedBatchBy`
- `chooseWeightedBatchByChecked`

The shared `rootValueTypeHasEmptyEnum` helper now catches empty enum fields in
regular structs as well as tuples and arrays. Pointer accessor-weighted helpers
are unchanged because they only return addresses into caller slices. The public
signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero uninhabited value types return `error.EmptyRange` before accessor
  calls, allocation, entropy, secure-engine construction, or value copying.
- Habitable value types keep existing accessor-weighted root behavior and stream
  shape.

## Adoption and Documentation

- Focused root tests cover scalar, fill, array, and batch accessor-weighted value
  choice failures for a value type containing an empty enum field, including
  failing allocator checks where relevant and no entropy request.
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
examplecheck ok
toolingcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M684 is closed for the current bar: root item-accessor weighted value choice
helpers now reject non-zero uninhabited value types before accessor weight
evaluation, allocation, entropy, secure-engine construction, value copying, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
