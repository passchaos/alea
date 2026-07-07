# S4-M692 Rng Value Choice Empty-Type Prevalidation

## Gap

`Rng` weighted value-choice helpers now reject non-zero empty enum-containing
value types before allocation or random-stream use. Unweighted `Rng` value-choice
helpers could still proceed toward singleton copying, output allocation, or index
sampling before reaching impossible value paths for uninhabited output types.

`Rng` unweighted value-choice helpers should reject non-zero uninhabited value
types before allocation, random-stream use, index sampling, or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes comparable slice choice APIs via
`IndexedRandom::choose`, `choose_multiple`, and related helpers in `src/seq`.
Rust returns references or clones only for inhabited values in ordinary use.

Alea's `Rng` value-returning choice helpers can name empty enum-containing value
types, so `error.EmptyRange` is the deterministic validation path for non-empty
checked/allocation-returning value outputs, while optional scalar/fixed-array
helpers return `null` before sampling.

## API Changed

`src/rng.zig` now prevalidates empty enum-containing value types in unweighted
value-choice helpers:

- `chooseFrom`
- `fillChooseCheckedFrom`
- `chooseValueArrayFrom`
- `chooseValueArrayCheckedFrom`
- `chooseBatchFrom`

`chooseCheckedFrom` and `chooseBatchCheckedFrom` inherit the prevalidation from
those helpers. Pointer choice helpers are unchanged because they return
addresses into caller-owned slices instead of constructing values. Public
signatures are unchanged.

Deterministic behavior is explicit:

- Zero-output/zero-size/zero-count requests still return before validating the
  value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` or `null`
  before output allocation, random-stream use, index sampling, or value copying.
- Empty input and checked empty-input validation keep existing precedence.
- Habitable value types keep existing choice behavior and stream shape.

## Adoption and Documentation

- Focused rng tests cover scalar optional, scalar checked, checked fill,
  allocation-returning, checked allocation-returning, optional fixed-array, and
  checked fixed-array choice failures. Empty-type tests use a regular struct
  containing an empty enum field and avoid formatting impossible success values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused rng tests:

```text
$ zig test src/rng.zig --test-filter "unweighted value choices validate empty value types before sampling"
1/2 rng.test.unweighted value choices validate empty value types before sampling...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "invalid facade choice helpers do not consume random stream"
1/2 rng.test.invalid facade choice helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/rng.zig --test-filter "single-item choice helpers do not consume random stream"
1/2 rng.test.single-item choice helpers do not consume random stream...OK
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
apicheck ok
toolingcheck ok
```

## Result

S4-M692 is closed for the current bar: `Rng` unweighted value-choice helpers now
reject non-zero empty enum-containing output types before allocation,
random-stream use, index sampling, value copying, or assertions. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
