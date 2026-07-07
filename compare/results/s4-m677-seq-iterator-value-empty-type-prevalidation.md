# S4-M677 Seq Iterator Reservoir Value Empty-Type Prevalidation

## Gap

Slice and reservoir value sampling now reject non-zero uninhabited value types
before allocation and sampling. Iterator reservoir value helpers could still
allocate buffers, consume iterators, or sample before reaching impossible value
paths for empty enum-containing value types.

`seq` iterator reservoir value helpers should reject non-zero empty
enum-containing value types before allocation, iterator consumption, and
random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes iterator reservoir sampling through
`IteratorRandom` workflows. Rust iterators cannot yield safe values of empty enum
types, so comparable invalid value-type states are ruled out before sampling.
Alea's Zig-native generic iterator helpers can name empty enum-containing value
types, so `error.EmptyInput` / `null` is the deterministic pre-sampling result.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `sampleIteratorFrom`
- `sampleIteratorCheckedFrom`
- `sampleIteratorArrayFrom`
- `sampleIteratorArrayCheckedFrom`
- `sampleIteratorIntoCheckedFrom`

The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/zero-size/empty-output requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return before allocation, iterator
  consumption, or random-stream use.
- Non-error caller-owned `sampleIteratorIntoFrom` remains unchanged because its
  signature has no error channel.
- Habitable value types keep existing iterator reservoir behavior and stream
  shape.

## Adoption and Documentation

- Focused seq tests cover owned, checked owned, optional fixed-array, checked
  fixed-array, and checked caller-owned iterator reservoir failures with failing
  allocators where relevant and zero random-stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "iterator reservoir samples validate empty value types before allocation"
1/2 seq.test.iterator reservoir samples validate empty value types before allocation...OK
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
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M677 is closed for the current bar: `seq` iterator reservoir value helpers now
reject non-zero empty enum-containing value types before allocation, iterator
consumption, random-stream use, or assertions. This is reliability and ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
