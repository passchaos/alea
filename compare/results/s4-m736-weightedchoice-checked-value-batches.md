# S4-M736 WeightedChoice Checked Value Batches

## Gap

Reusable `Choice` now has checked caller-owned and allocation-returning
value-copy batch aliases. Reusable `WeightedChoice` still only exposed unchecked
names for those weighted value-copy batch shapes, even though non-zero empty
enum-containing value outputs need explicit failure before random-stream use,
allocation, or value copying.

Reusable `WeightedChoice` should provide checked value batch aliases that return
a seq-style error before random-stream use, allocation, or value copying for
empty enum-containing value types.

## Local `rand` Baseline

The local Rust `rand` checkout exposes repeated weighted choice workflows through
reference-oriented weighted slice choice and iterator collection. Alea's reusable
`WeightedChoice(T, Weight)` exceeds the reference-only shape with weighted
value-copy fills and owned batches; checked aliases make those value-copy batch
paths explicit for fallible Zig workflows involving uninhabited value types.

## API Added

`src/seq.zig` adds checked value batch aliases to `WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).fillValuesChecked`
- `WeightedChoice(T, Weight).fillValuesCheckedFrom`
- `WeightedChoice(T, Weight).valuesChecked`
- `WeightedChoice(T, Weight).valuesCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Checked value-fill aliases preserve `fillValuesFrom` stream shape for inhabited
  value types.
- Checked owned value aliases preserve `valuesFrom` stream shape for inhabited
  value types.
- Non-empty empty enum-containing value outputs return `error.EmptyInput` before
  random-stream use, allocation, or value copying.
- Zero-length checked fills and owned batches preserve existing no-consumption /
  zero-allocation-shape behavior.

## Adoption and Documentation

- Focused weighted-choice tests compare checked and unchecked caller-owned value
  fills and owned value batches for stream parity.
- Empty-type tests cover `fillValuesCheckedFrom` and `valuesCheckedFrom`
  returning `error.EmptyInput` with zero stream consumption and no induced
  allocation failure.
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
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M736 is closed for the current bar: reusable `WeightedChoice` now has checked
aliases for caller-owned and allocation-returning weighted value-copy batches.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
