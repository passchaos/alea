# S4-M678 Root Iterator Reservoir Value Empty-Type Prevalidation

## Gap

`seq` iterator reservoir value helpers now reject non-zero uninhabited value types
before allocation and iterator consumption. Root iterator reservoir helpers could
still allocate buffers, consume iterators, or request entropy for empty
enum-containing value types.

Root iterator reservoir value helpers should reject non-zero empty
enum-containing value types before allocation, entropy, iterator consumption, and
secure-engine construction.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator reservoir sampling through
`IteratorRandom` workflows. Rust iterators cannot yield safe values of empty enum
types, so comparable invalid value-type states are ruled out before sampling.
Alea's Zig-native root iterator helpers can name empty enum-containing value
types, so `error.EmptyRange` is the deterministic pre-sampling validation path.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `sampleIterator`
- `sampleIteratorChecked`
- `sampleIteratorInto`
- `sampleIteratorIntoChecked`
- `sampleIteratorArray`
- `sampleIteratorArrayChecked`

`sampleIteratorFill` aliases inherit the behavior. The public signatures are
unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  allocation, entropy, iterator consumption, secure-engine construction, or
  random-stream use.
- Habitable value types keep existing iterator reservoir behavior and stream
  shape.

## Adoption and Documentation

- Focused root tests cover owned, checked owned, caller-owned, checked
  caller-owned, optional fixed-array, and checked fixed-array iterator reservoir
  failures with failing allocators where relevant and no entropy request.
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
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M678 is closed for the current bar: root iterator reservoir value helpers now
reject non-zero empty enum-containing value types before allocation, entropy,
iterator consumption, secure-engine construction, random-stream use, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
