# S4-M696 Seq Iterator Choice Empty-Type Prevalidation

## Gap

`seq` one-shot slice value choices now reject non-empty empty enum-containing
value types before sampling. Iterator one-shot value choices could still consume
iterators or draw from the random stream before reaching impossible value paths
for uninhabited output types.

`seq.chooseIterator*` value helpers should reject uninhabited output types before
iterator consumption, random-stream use, or value copying while preserving
seq-style checked errors.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator/slice choice workflows returning
references or inhabited values in normal use. Rust's type flow avoids
constructing impossible output values, while Alea's Zig-native iterator value
choice helpers can name empty enum-containing output types.

For Alea, optional iterator choices return `null` and checked variants return
`error.EmptyInput` before consuming iterators for uninhabited value types.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseIteratorFrom`
- `chooseIteratorExactRemainingFrom`

The public wrappers and aliases inherit this behavior:
`chooseIterator`, `chooseIteratorChecked`, `chooseIteratorHinted`,
`chooseIteratorHintedChecked`, `chooseIteratorStable`, and
`chooseIteratorStableChecked`.

Public signatures are unchanged.

Deterministic behavior is explicit:

- Empty iterators still return `null` / `error.EmptyInput` without random-stream
  use.
- Empty enum-containing value types return `null` / `error.EmptyInput` before
  iterator consumption, random-stream use, or value copying.
- Habitable value types keep existing reservoir/exact-hint stream behavior.

## Adoption and Documentation

- Focused seq tests cover optional, checked, hinted exact-remaining, and stable
  checked iterator choices for a regular struct containing an empty enum field.
  The test iterator would `unreachable` if consumed, proving pre-consumption
  behavior; stream state is also checked.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq tests:

```text
$ zig test src/seq.zig --test-filter "iterator choices validate empty value types before consuming iterators"
1/2 seq.test.iterator choices validate empty value types before consuming iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "empty facade iterator choices do not consume random stream"
1/2 seq.test.empty facade iterator choices do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/seq.zig --test-filter "hinted iterator choice uses exact-size hints when available"
1/2 seq.test.hinted iterator choice uses exact-size hints when available...OK
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
readmecheck ok
apicheck ok
```

## Result

S4-M696 is closed for the current bar: `seq` iterator one-shot value choices now
reject empty enum-containing output types before iterator consumption,
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
