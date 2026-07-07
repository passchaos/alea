# S4-M697 Root Iterator Choice Empty-Type Prevalidation

## Gap

`seq` iterator one-shot value choices now reject empty enum-containing output
types before iterator consumption. Root iterator one-shot value choice wrappers
could still call into the root iterator choice machinery, potentially consuming
iterators or constructing a secure engine before reaching impossible value paths
for uninhabited output types.

Root `chooseIterator*` value helpers should reject uninhabited output types before
iterator consumption, entropy, secure-engine construction, random-stream use, or
value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator/slice choice workflows returning
references or inhabited values in normal use. Rust's type flow avoids
constructing impossible output values, while Alea's Zig-native root iterator
choice helpers can name empty enum-containing output types.

For Alea, root iterator value choices return `error.EmptyRange` for uninhabited
value types before touching the iterator or entropy source.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `chooseIterator`
- `chooseIteratorChecked`
- `chooseIteratorHinted`
- `chooseIteratorHintedChecked`
- `chooseIteratorStable`
- `chooseIteratorStableChecked`

Public signatures are unchanged.

Deterministic behavior is explicit:

- Empty iterators of habitable value types still return `null` /
  `error.EmptyInput` without entropy.
- Empty enum-containing value types return `error.EmptyRange` before iterator
  consumption, entropy, secure-engine construction, random-stream use, or value
  copying.
- Habitable value types keep existing reservoir/exact-hint behavior and entropy
  boundaries.

## Adoption and Documentation

- Focused root tests cover optional, checked, hinted, and stable checked iterator
  choices for a regular struct containing an empty enum field. The test iterator
  would `unreachable` if consumed, proving pre-consumption behavior under
  `std.Io.failing`.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root test:

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
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
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M697 is closed for the current bar: root iterator one-shot value choices now
reject empty enum-containing output types before iterator consumption, entropy,
secure-engine construction, random-stream use, value copying, or assertions. This
is reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
