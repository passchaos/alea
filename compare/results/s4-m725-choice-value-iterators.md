# S4-M725 Choice Value Iterators

## Gap

Distribution-layer `Choose` now exposes reusable value iterators and checked
value-iterator aliases. Reusable `seq.Choice` still only exposed pointer/index
iterators plus caller-owned/owned value batches, leaving repeated value-copy
sampling without an iterator-shaped API.

Reusable `Choice` should expose value iterators that mirror its `fillValues*`
stream shape and provide a checked constructor for empty enum-containing output
types.

## Local `rand` Baseline

The local Rust `rand` checkout supports repeated choice workflows through
iterator adapters over distributions and slice choice references. Alea's
`Choice(T)` already exceeds the reference-only shape with value-copy fills and
owned batches, so value iterators complete the same repeated-sampling ergonomic
path without forcing allocation.

## API Added

`src/seq.zig` adds reusable value iterator helpers to `Choice(T)`:

- `Choice(T).valueIter`
- `Choice(T).valueIterFrom`
- `Choice(T).valueIterChecked`
- `Choice(T).valueIterCheckedFrom`
- `Choice(T).ValueIterator`
- `Choice(T).ValueIterator.next`
- `Choice(T).ValueIterator.nextValue`
- `Choice(T).ValueIterator.fill`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- `ValueIterator.fill` mirrors `Choice.fillValuesFrom` stream shape.
- Checked value iterator construction returns `error.EmptyInput` for empty
  enum-containing value types before random-stream use.
- Unchecked empty-type value iterators produce `null` without consuming the
  stream, matching the no-op unchecked value-fill behavior.

## Adoption and Documentation

- Focused seq tests compare value-iterator fill output/stream shape against
  `fillValuesFrom`.
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
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
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
roadmapcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M725 is closed for the current bar: reusable `Choice` now has value iterator
helpers with checked empty-type construction. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
