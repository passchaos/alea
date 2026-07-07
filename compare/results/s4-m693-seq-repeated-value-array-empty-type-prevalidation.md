# S4-M693 Seq Repeated Value Array Empty-Type Prevalidation

## Gap

`Rng` unweighted value-choice helpers now reject non-zero empty enum-containing
value types before sampling. The `seq` repeated with-replacement fixed-size value
array alias could still call into fill-based value copying for an uninhabited
output type.

`seq.chooseRepeatedValueArray*` should reject non-zero uninhabited value types
before random-stream use or value copying, matching the newer `Rng` fixed value
array behavior.

## Local `rand` Baseline

The local Rust `rand` checkout exposes repeated slice choice workflows via
`IndexedRandom::choose` and iterator/adaptor forms returning references. Rust's
normal type flow avoids constructing impossible output values, while Alea's
Zig-native fixed value arrays can name empty enum-containing output types.

For Alea, optional repeated value arrays return `null` and checked variants
return `error.EmptyInput` for non-zero uninhabited output requests.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseRepeatedValueArrayFrom`
- `chooseRepeatedValueArrayCheckedFrom` (inherited through the optional helper)

Pointer repeated array helpers are unchanged because they return addresses into
caller-owned slices. Public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-size requests still return before validating the value type.
- Non-zero empty enum-containing value types return `null` / `error.EmptyInput`
  before random-stream use or value copying.
- Empty input and singleton deterministic behavior remain unchanged for
  habitable value types.

## Adoption and Documentation

- Focused seq tests cover optional and checked fixed repeated value arrays for a
  regular struct containing an empty enum field, with zero stream consumption.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "seq repeated choice arrays mirror Rng fixed choice arrays"
1/2 seq.test.seq repeated choice arrays mirror Rng fixed choice arrays...OK
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
examplecheck ok
roadmapcheck ok
```

## Result

S4-M693 is closed for the current bar: `seq` repeated with-replacement fixed
value arrays now reject non-zero empty enum-containing output types before
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
