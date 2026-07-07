# S4-M663 Rng Value Batch Empty-Type Prevalidation

## Gap

Checked `Rng` value batch helpers validate uninhabited value types before
allocation. The unchecked `valueBatchFrom` helper allocated first and then filled
through `valueIterFrom`, so non-zero empty enum-containing value types could fail
after allocation or via assertions.

Unchecked value batch helpers should reject non-zero uninhabited value types
before allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes `StandardUniform` implementations for
supported value types, arrays, and tuples. Rust's type system prevents sampling
unsupported/uninhabited value combinations in those implementations. Alea's
Zig-native `value(T)` supports enums, arrays, and tuples and therefore exposes a
runtime `error.EmptyRange` path for empty enum-containing value types; S4-M663
applies that pre-sampling validation to unchecked owned batches.

## API Changed

`src/rng.zig` now prevalidates empty enum-containing value types in:

- `valueBatchFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validating the value
  type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  allocation and random-stream use.
- Habitable value types still allocate the output buffer and keep existing stream
  shape.

## Adoption and Documentation

- Focused rng tests cover direct unchecked empty-enum and tuple-containing-empty
  enum batch requests before allocation and stream consumption, plus existing
  checked and zero-count behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng test:

```text
$ zig test src/rng.zig --test-filter "owned checked values validate empty enums before consuming random stream"
1/2 rng.test.owned checked values validate empty enums before consuming random stream...OK
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

S4-M663 is closed for the current bar: `Rng` unchecked value batch helpers now
reject non-zero empty enum-containing value types before allocation,
random-stream use, or assertions. This is reliability and ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
