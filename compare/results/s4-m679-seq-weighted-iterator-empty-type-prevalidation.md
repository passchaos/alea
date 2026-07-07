# S4-M679 Seq Weighted Iterator Reservoir Empty-Type Prevalidation

## Gap

Unweighted iterator reservoir value helpers now reject non-zero uninhabited value
types before allocation and sampling. Weighted iterator reservoir value helpers
could still allocate heaps, consume iterators, or draw random weighted keys before
reaching impossible value paths for empty enum-containing value types.

`seq` weighted iterator reservoir value helpers should reject non-zero empty
enum-containing value types before heap allocation, iterator consumption, and
random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes weighted iterator sampling workflows where
impossible value types are ruled out by the type system before sampling. Alea's
Zig-native weighted iterator reservoir APIs can name empty enum-containing value
types, so `error.EmptyInput` is the deterministic pre-sampling validation path.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `sampleIteratorWeightedFrom`
- `sampleIteratorWeightedCheckedFrom`
- `sampleIteratorWeightedIntoFrom`
- `sampleIteratorWeightedIntoCheckedFrom`
- `sampleIteratorWeightedArrayFrom`
- `sampleIteratorWeightedArrayCheckedFrom`

The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  heap allocation, iterator consumption, random-key generation, or value copying.
- Habitable value types keep existing weighted iterator reservoir behavior and
  stream shape.

## Adoption and Documentation

- Focused seq tests cover owned, checked owned, optional fixed-array, checked
  fixed-array, caller-owned, and checked caller-owned weighted iterator reservoir
  failures with failing allocators where relevant and zero random-stream
  consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "weighted iterator reservoir samples validate empty value types before allocation"
1/2 seq.test.weighted iterator reservoir samples validate empty value types before allocation...OK
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

S4-M679 is closed for the current bar: `seq` weighted iterator reservoir value
helpers now reject non-zero empty enum-containing value types before heap
allocation, iterator consumption, random-stream use, random-key generation, or
assertions. This is reliability and ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
