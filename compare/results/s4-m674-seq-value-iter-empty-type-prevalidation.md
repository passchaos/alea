# S4-M674 Seq Sampled Value Iterator Empty-Type Prevalidation

## Gap

`seq` owned value samples now reject non-zero uninhabited value types before
allocation and sampling. Sampled value iterator helpers could still allocate an
owned index vector and sample indices before returning an iterator whose value
type is uninhabited.

`seq` sampled value iterators should reject non-zero empty enum-containing value
types before index allocation and before random-stream use.

## Local `rand` Baseline

The local Rust `rand` checkout exposes sampled slice iterators through
`IndexedSamples` / `choose_multiple` style workflows. Rust slices cannot contain
safe values of empty enum types, so comparable invalid value-type states are
ruled out before sampling. Alea's Zig-native sampled value iterators can name
empty enum-containing value types, so `error.EmptyInput` is the deterministic
pre-sampling validation path.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `sampleItemsIterFrom`
- `sampleItemsIterCheckedFrom`

The public signatures are unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-count sampled iterators still return empty iterators before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyInput` before
  index allocation and random-stream use.
- Oversized checked requests keep existing `error.InvalidParameter` behavior.
- Habitable value types keep existing iterator behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover unchecked and checked empty-enum sampled value iterator
  requests with failing allocators and zero random-stream consumption, plus
  existing zero-count iterator behavior.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "sampleItemsIter owns sampled indices and streams values"
1/2 seq.test.sampleItemsIter owns sampled indices and streams values...OK
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
readmecheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M674 is closed for the current bar: `seq` sampled value iterator helpers now
reject non-zero empty enum-containing value types before index allocation,
random-stream use, iterator construction, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
