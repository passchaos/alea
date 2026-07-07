# S4-M672 Seq Caller-Owned Value Sample Empty-Type Prevalidation

## Gap

Root caller-owned no-replacement value buffers now reject non-zero uninhabited
value types before entropy. The lower-level `seq` caller-owned value buffer
helpers could still sample indices and then copy values for empty enum-containing
value types.

`seq` caller-owned no-replacement value buffers should reject non-zero empty
enum-containing value types before index sampling and before value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes no-replacement slice workflows through
`choose_multiple` and sample/collect patterns. Rust slices cannot contain safe
values of empty enum types, so comparable invalid value-type states are ruled out
before sampling. Alea's Zig-native `seq` caller-owned buffers can name empty
enum-containing value types, so the seq-style invalid input result is
`error.EmptyInput` before sampling.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseMultipleIntoFrom`
- `chooseMultipleIntoCheckedFrom`

`sampleItemsInto` aliases inherit the behavior. The public signatures are
unchanged.

Deterministic pre-stream behavior is explicit:

- Empty output buffers still return before validating the value type.
- Non-empty empty enum-containing value types return `error.EmptyInput` before
  index sampling and value copying.
- Scratch-length validation for habitable value types keeps existing behavior.
- Habitable value types keep existing optional/checked behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover optional and checked empty-enum caller-owned value
  buffer failures with zero random-stream consumption, plus existing zero-output
  and scratch validation behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "chooseMultipleInto validates empty value types before sampling"
1/2 seq.test.chooseMultipleInto validates empty value types before sampling...OK
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
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M672 is closed for the current bar: `seq` caller-owned no-replacement value
buffer helpers now reject non-zero empty enum-containing value types before index
sampling, value copying, random-stream use, or assertions. This is reliability
and ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
