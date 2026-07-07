# S4-M726 WeightedChoice Value Iterators

## Gap

Reusable `Choice` now exposes allocation-free value iterators with checked
empty-type construction. Reusable `WeightedChoice` still only exposed pointer and
index iterators plus caller-owned/owned value batches, leaving repeated weighted
value-copy sampling without the same iterator-shaped API.

Reusable `WeightedChoice` should expose value iterators that mirror
`fillValues*` stream shape and provide a checked constructor for empty
enum-containing output types.

## Local `rand` Baseline

The local Rust `rand` checkout supports repeated weighted choice workflows via
weighted slice choice and iterator-style sampling over reusable distributions.
Alea's reusable `WeightedChoice(T, Weight)` already exceeds the reference-only
shape with value-copy fills and owned batches, so value iterators complete the
same repeated weighted value-copy ergonomic path without forcing allocation.

## API Added

`src/seq.zig` adds reusable value iterator helpers to
`WeightedChoice(T, Weight)`:

- `WeightedChoice(T, Weight).valueIter`
- `WeightedChoice(T, Weight).valueIterFrom`
- `WeightedChoice(T, Weight).valueIterChecked`
- `WeightedChoice(T, Weight).valueIterCheckedFrom`
- `WeightedChoice(T, Weight).ValueIterator`
- `WeightedChoice(T, Weight).ValueIterator.next`
- `WeightedChoice(T, Weight).ValueIterator.nextValue`
- `WeightedChoice(T, Weight).ValueIterator.fill`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- `ValueIterator.fill` mirrors `WeightedChoice.fillValuesFrom` stream shape.
- Checked value iterator construction returns `error.EmptyInput` for empty
  enum-containing value types before random-stream use.
- Unchecked empty-type value iterators produce `null` without consuming the
  stream, matching the no-op unchecked value-fill behavior.

## Adoption and Documentation

- Focused weighted-choice tests compare value-iterator fill output/stream shape
  against `fillValuesFrom`.
- Tests compare checked and unchecked value-iterator scalar draws for stream
  parity.
- Empty-type tests cover unchecked iterator `null`, checked constructor
  `error.EmptyInput`, and zero stream consumption.
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
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M726 is closed for the current bar: reusable `WeightedChoice` now has value
iterator helpers with checked empty-type construction. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
