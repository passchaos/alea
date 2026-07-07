# S4-M699 Root Sampled Value Iterator Empty-Type Prevalidation

## Gap

Root iterator one-shot value choices now reject empty enum-containing output
types before iterator consumption. Root sampled value iterator aliases
(`sampleItemsIter*`) could still take deterministic all-index fast paths and
construct `SampledValueIterator(T)` values for uninhabited `T`, deferring failure
to later impossible value access.

Root sampled value iterator aliases should reject non-zero uninhabited value
types before index allocation, entropy, secure-engine construction, random-stream
use, iterator construction, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes sampled slice iterator workflows over
references. Rust's normal type flow avoids constructing impossible output values,
while Alea's Zig-native sampled value iterators can name empty enum-containing
output types.

For Alea, root sampled value iterator aliases return `error.EmptyRange` for
non-zero uninhabited value types before allocating index storage or creating an
iterator.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `sampleItemsIter`
- `sampleItemsIterChecked`

Pointer sampled iterator helpers are unchanged because they yield addresses into
caller-owned slices. Public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-amount requests still return an empty iterator before validating the value
  type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  index allocation, entropy, secure-engine construction, random-stream use,
  iterator construction, or value copying.
- Oversized checked requests keep existing `error.InvalidParameter` precedence.
- Habitable value types keep existing all-items and random-sampling behavior.

## Adoption and Documentation

- Focused root tests cover unchecked and checked sampled value iterator failures
  for empty enum output types with failing allocators, proving preallocation
  behavior under `std.Io.failing`.
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
toolingcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M699 is closed for the current bar: root sampled value iterator aliases now
reject non-zero empty enum-containing output types before allocation, entropy,
secure-engine construction, random-stream use, iterator construction, value
copying, or assertions. This is reliability and ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
