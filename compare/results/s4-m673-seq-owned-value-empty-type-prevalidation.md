# S4-M673 Seq Owned Value Sample Empty-Type Prevalidation

## Gap

`seq` fixed-size and caller-owned no-replacement value helpers now reject non-zero
uninhabited value types before sampling. Allocation-returning value sample helpers
could still allocate output and index buffers before failing or reaching
impossible value-copying paths.

`seq` owned no-replacement value samples should reject non-zero empty
enum-containing value types before output/index allocation and before
random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes no-replacement slice workflows through
`choose_multiple` and sample/collect patterns. Rust slices cannot contain safe
values of empty enum types, so comparable invalid value-type states are ruled out
before sampling. Alea's Zig-native `seq` owned value samples can name empty
enum-containing value types, so the seq-style invalid input result is
`error.EmptyInput` before allocation or sampling.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseMultipleFrom`
- `chooseMultipleCheckedFrom`

`sampleItems` aliases inherit the behavior. The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count requests still return empty allocations before validating the value
  type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  output allocation, index allocation, and random-stream use.
- Oversized checked requests keep existing `error.InvalidParameter` behavior.
- Habitable value types keep existing optional/checked behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover unchecked and checked empty-enum owned value samples
  with failing allocators and zero random-stream consumption, plus existing
  zero-count behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "chooseMultiple owned samples validate empty value types before allocation"
1/2 seq.test.chooseMultiple owned samples validate empty value types before allocation...OK
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
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M673 is closed for the current bar: `seq` allocation-returning no-replacement
value sample helpers now reject non-zero empty enum-containing value types before
output allocation, index allocation, random-stream use, or assertions. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
