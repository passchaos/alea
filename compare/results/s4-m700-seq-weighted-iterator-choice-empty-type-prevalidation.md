# S4-M700 Seq Weighted Iterator Choice Empty-Type Prevalidation

## Gap

Root weighted iterator choices and `seq` unweighted iterator choices now reject
empty enum-containing output types before iterator consumption. `seq` weighted
iterator one-shot value choices could still consume weighted iterators, evaluate
weights, or draw random values before reaching impossible value paths for
uninhabited output types.

`seq.chooseIteratorWeighted*` should reject uninhabited output types before
iterator consumption, weight evaluation, random-stream use, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted iterator/slice choice workflows
returning references or inhabited values in normal use. Rust's type flow avoids
constructing impossible output values, while Alea's Zig-native weighted iterator
choice helpers can name empty enum-containing output types.

For Alea, seq-style weighted iterator choices return `error.EmptyInput` for
uninhabited value types before touching the iterator or random source.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseIteratorWeightedFrom`
- `chooseIteratorWeightedCheckedFrom`

Public wrappers `chooseIteratorWeighted` and `chooseIteratorWeightedChecked`
inherit this behavior. Public signatures are unchanged.

Deterministic behavior is explicit:

- Empty or zero-positive weighted iterators of habitable value types still return
  `null` / `error.EmptyInput` without random-stream use.
- Empty enum-containing value types return `error.EmptyInput` before iterator
  consumption, weight evaluation, random-stream use, or value copying.
- Habitable value types keep existing weighted reservoir choice behavior and
  stream shape.

## Adoption and Documentation

- Focused seq tests cover optional and checked weighted iterator choices for a
  regular struct containing an empty enum field. The test iterator would
  `unreachable` if consumed, proving pre-consumption behavior.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "weighted iterator choices validate empty value types before consuming iterators"
1/2 seq.test.weighted iterator choices validate empty value types before consuming iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "empty checked weighted iterator choice does not consume random stream"
1/2 seq.test.empty checked weighted iterator choice does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "weighted iterator choice works without collecting first"
1/2 seq.test.weighted iterator choice works without collecting first...OK
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
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M700 is closed for the current bar: `seq` weighted iterator one-shot value
choices now reject empty enum-containing output types before iterator
consumption, weight evaluation, random-stream use, value copying, or assertions.
This is reliability and ergonomics work only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
