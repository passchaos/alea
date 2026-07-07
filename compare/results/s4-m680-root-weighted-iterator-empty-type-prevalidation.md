# S4-M680 Root Weighted Iterator Reservoir Empty-Type Prevalidation

## Gap

`seq` weighted iterator reservoir value helpers now reject non-zero uninhabited
value types before heap allocation and sampling. Root weighted iterator reservoir
helpers could still allocate buffers, consume iterators, or request entropy for
empty enum-containing value types.

Root weighted iterator reservoir value helpers should reject non-zero empty
enum-containing value types before allocation, entropy, iterator consumption,
heap allocation, and secure-engine construction.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted iterator sampling workflows where
impossible value types are ruled out by the type system before sampling. Alea's
Zig-native root weighted iterator helpers can name empty enum-containing value
types, so `error.EmptyRange` is the deterministic pre-sampling validation path.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `sampleIteratorWeighted`
- `sampleIteratorWeightedChecked`
- `sampleIteratorWeightedInto`
- `sampleIteratorWeightedIntoChecked`
- `sampleIteratorWeightedArray`
- `sampleIteratorWeightedArrayChecked`

The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  allocation, entropy, iterator consumption, heap allocation, secure-engine
  construction, or random-key generation.
- Habitable value types keep existing weighted iterator reservoir behavior and
  stream shape.

## Adoption and Documentation

- Focused root tests cover owned, checked owned, caller-owned, checked
  caller-owned, optional fixed-array, and checked fixed-array weighted iterator
  reservoir failures with failing allocators where relevant and no entropy
  request.
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
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M680 is closed for the current bar: root weighted iterator reservoir value
helpers now reject non-zero empty enum-containing value types before allocation,
entropy, iterator consumption, heap allocation, secure-engine construction,
random-key generation, or assertions. This is reliability and ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
