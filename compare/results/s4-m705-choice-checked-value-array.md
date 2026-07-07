# S4-M705 Choice Checked Value Array

## Gap

`Choice` owned and caller-owned value-copy helpers now avoid impossible empty
enum-containing value outputs. Fixed-size value arrays still only had infallible
`valueArray*` helpers, so users lacked a checked API that reports uninhabited
output types instead of returning an impossible value array.

A Zig-native checked fixed-size value array helper should provide an explicit
`error.EmptyInput` path for non-zero uninhabited value types while keeping
zero-size arrays deterministic.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice samplers returning references
or inhabited values in normal use. Rust's type flow avoids constructing
impossible output values, while Alea's `Choice(T)` fixed value arrays can name
empty enum-containing output types.

For Alea, checked fixed-size value arrays return `error.EmptyInput` for non-zero
uninhabited value types before random-stream use or value copying.

## API Added

`src/seq.zig` adds checked fixed-size value array helpers to `Choice(T)`:

- `Choice(T).valueArrayChecked`
- `Choice(T).valueArrayCheckedFrom`

Public existing APIs are unchanged.

Deterministic behavior is explicit:

- Zero-size checked arrays return immediately before validating the value type.
- Non-zero empty enum-containing value arrays return `error.EmptyInput` before
  random-stream use or value copying.
- Habitable value types use the existing value-fill behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover `Choice(Empty).valueArrayCheckedFrom` for non-zero
  `error.EmptyInput`, zero-size success, and zero stream consumption.
- Tests avoid `expectError` where the success payload contains an empty enum,
  preventing Zig's test formatter from trying to print impossible values.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
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
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M705 is closed for the current bar: reusable `Choice` now has checked
fixed-size value array helpers that reject non-zero empty enum-containing output
types before random-stream use, value copying, or assertions. This is reliability
and ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
