# S4-M724 WeightedChoice Checked Values

## Gap

Reusable `Choice` and distribution-layer `Choose` now expose checked scalar
value-copy helpers. Reusable `WeightedChoice` still only had infallible
`sampleValue*`, leaving weighted reusable samplers without the same explicit
empty-type error path for scalar value-copy workflows.

Reusable `WeightedChoice` should expose checked scalar value helpers that return
seq-style errors before random-stream use or value copying when the output type
contains an empty enum.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted slice choice workflows returning
references over inhabited items. Alea's reusable `WeightedChoice(T, Weight)` also
exposes value-copy helpers, so checked scalar value-copy APIs improve Zig-native
fallible workflows for uninhabited `T` while preserving pointer-oriented parity.

## API Added

`src/seq.zig` adds checked scalar value helpers to `WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).sampleValueChecked`
- `WeightedChoice(T, Weight).sampleValueCheckedFrom`
- `WeightedChoice(T, Weight).valueChecked`
- `WeightedChoice(T, Weight).valueCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Empty enum-containing value types return `error.EmptyInput` before
  random-stream use or value copying.
- Habitable value types preserve the same stream shape as `sampleValueFrom`.

## Adoption and Documentation

- Focused weighted-choice tests compare checked and unchecked scalar value
  sampling for stream-shape parity, and cover
  `WeightedChoice(Empty, Weight).sampleValueCheckedFrom` / `valueCheckedFrom`
  with zero stream consumption.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
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
readmecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M724 is closed for the current bar: reusable `WeightedChoice` now has checked
scalar value-copy helpers with empty-type failures before random-stream use,
value copying, or assertions. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
