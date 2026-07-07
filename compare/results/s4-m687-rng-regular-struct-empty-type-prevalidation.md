# S4-M687 Rng Regular-Struct Empty-Type Prevalidation

## Gap

`Rng` empty-type prevalidation caught empty enums in arrays and tuple structs, but
regular structs containing empty enum fields were not recognized. This left
allocation-returning and no-replacement APIs able to proceed toward allocation or
sampling for uninhabited value types that Zig can name but cannot instantiate.

`Rng` empty-type detection should reject regular structs containing empty enum
fields before allocation and random-stream use, matching the existing tuple
behavior.

## Local `rand` Baseline

The local Rust `rand` checkout relies on Rust's type system and trait impls to
prevent sampling unsupported or uninhabited value types in comparable generic
sampling workflows. Alea's Zig-native APIs can name value types containing empty
enum fields, so `error.EmptyRange` is the deterministic pre-sampling validation
path.

## API Changed

`src/rng.zig` now extends `valueTypeHasEmptyEnum` to inspect all struct fields,
not only tuple structs.

The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count requests still return before validating the value type.
- Non-zero regular structs containing empty enum fields return `error.EmptyRange`
  before allocation and random-stream use.
- Existing tuple/array/empty-enum validation behavior is preserved.
- Habitable value types keep existing behavior and stream shape.

## Adoption and Documentation

- Focused rng tests cover named regular structs containing empty enum fields in
  `valueBatchFrom`, `sampleBatchFrom`, and `sampleWithoutReplacementCheckedFrom`
  before allocation and stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "sample without replacement validates empty value types before allocation"
1/2 rng.test.sample without replacement validates empty value types before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "owned checked values validate empty enums before consuming random stream"
1/2 rng.test.owned checked values validate empty enums before consuming random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "owned sampler batches validate empty output types before consuming random stream"
1/2 rng.test.owned sampler batches validate empty output types before consuming random stream...OK
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
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M687 is closed for the current bar: `Rng` empty-type prevalidation now rejects
regular structs containing empty enum fields before allocation, random-stream
use, value construction, or assertions. This is reliability and ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
