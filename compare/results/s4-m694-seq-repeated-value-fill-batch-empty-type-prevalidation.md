# S4-M694 Seq Repeated Value Fill/Batch Empty-Type Prevalidation

## Gap

`seq` repeated fixed value arrays now reject non-zero empty enum-containing value
types before random-stream use. The remaining `seq` repeated with-replacement
value fill/batch aliases could still forward into `Rng` paths for an uninhabited
output type, losing the seq-style `error.EmptyInput` contract and reaching
impossible value-copying paths.

`seq` repeated value fill/batch aliases should reject non-empty uninhabited value
outputs before allocation, random-stream use, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes repeated slice choice workflows via
`IndexedRandom::choose` and iterator/adaptor forms returning references. Rust's
normal type flow avoids constructing impossible output values, while Alea's
Zig-native fill and owned-batch value helpers can name empty enum-containing
output types.

For Alea, seq-style checked fill/batch aliases return `error.EmptyInput` for
non-empty uninhabited output requests.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `fillChooseCheckedFrom`
- `chooseBatchFrom`
- `chooseBatchCheckedFrom` (inherited through `chooseBatchFrom`)

Pointer repeated fill/batch helpers are unchanged because they return addresses
into caller-owned slices. Public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-output/zero-count requests still return before validating the value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  allocation, random-stream use, or value copying.
- Empty input and singleton deterministic behavior remain unchanged for
  habitable value types.

## Adoption and Documentation

- Focused seq tests cover checked fill, unchecked owned batch, and checked owned
  batch failures for a regular struct containing an empty enum field, with zero
  stream consumption and failing allocators proving preallocation behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "seq choice fill aliases mirror Rng fill helpers"
1/2 seq.test.seq choice fill aliases mirror Rng fill helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "seq choice batch aliases mirror Rng batch helpers"
1/2 seq.test.seq choice batch aliases mirror Rng batch helpers...OK
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
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M694 is closed for the current bar: `seq` repeated value fill/batch aliases
now reject non-zero empty enum-containing output types before allocation,
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
