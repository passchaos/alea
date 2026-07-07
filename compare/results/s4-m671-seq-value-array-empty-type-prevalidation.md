# S4-M671 Seq Fixed Value Array Empty-Type Prevalidation

## Gap

Root fixed-size no-replacement value arrays now reject non-zero uninhabited value
types before entropy. The lower-level `seq` fixed value array helpers could still
sample indices and then copy values for empty enum-containing value types.

`seq` fixed no-replacement value arrays should reject non-zero empty
enum-containing value types before index sampling and before value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes fixed-size slice sampling through
sample-array style workflows. Rust slices cannot contain safe values of empty enum
types, so comparable invalid value-type states are ruled out before sampling.
Alea's Zig-native `seq` APIs can name empty enum-containing value types, so the
seq-style invalid input result is deterministic failure before sampling.

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `chooseArrayFrom`
- `chooseArrayCheckedFrom`

`sampleItemsArray` aliases inherit the behavior. The public signatures are
unchanged.

Deterministic pre-stream behavior is explicit:

- Zero-size arrays still return before validating the value type.
- Optional `chooseArrayFrom` returns `null` for non-zero empty enum-containing
  value types before index sampling.
- Checked `chooseArrayCheckedFrom` returns `error.EmptyInput` for non-zero empty
  enum-containing value types before index sampling.
- Habitable value types keep existing optional/checked behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover optional and checked empty-enum fixed value array
  failures with zero random-stream consumption, plus existing oversized-count
  invalid paths.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "invalid chooseArray helpers do not consume random stream"
1/2 seq.test.invalid chooseArray helpers do not consume random stream...OK
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
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M671 is closed for the current bar: `seq` fixed-size no-replacement value
array helpers now reject non-zero empty enum-containing value types before index
sampling, value copying, random-stream use, or assertions. This is reliability
and ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
