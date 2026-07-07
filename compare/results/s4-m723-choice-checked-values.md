# S4-M723 Choice Checked Values

## Gap

Distribution-layer `Choose` now has checked scalar value-copy helpers. Reusable
`seq.Choice` still only had infallible `sampleValue*`, leaving users without a
checked scalar value-copy API for empty enum-containing output types.

Reusable `Choice` should expose checked scalar value helpers that return an
explicit seq-style error before random-stream use or value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes slice choice samplers returning references
over inhabited items. Alea's reusable `Choice(T)` also exposes value-copy helpers,
so checked scalar value-copy APIs improve Zig-native fallible workflows for
uninhabited `T`.

## API Added

`src/seq.zig` adds checked scalar value helpers to `Choice(T)`:

- `Choice(T).sampleValueChecked`
- `Choice(T).sampleValueCheckedFrom`
- `Choice(T).valueChecked`
- `Choice(T).valueCheckedFrom`

`docs/api-reference.md` lists the new public symbols. Existing APIs are
unchanged.

Deterministic behavior is explicit:

- Empty enum-containing value types return `error.EmptyInput` before
  random-stream use or value copying.
- Habitable value types preserve the same stream shape as `sampleValueFrom`.

## Adoption and Documentation

- Focused seq tests compare checked and unchecked scalar value sampling for
  stream-shape parity, and cover `Choice(Empty).sampleValueCheckedFrom` /
  `valueCheckedFrom` with zero stream consumption.
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M723 is closed for the current bar: reusable `Choice` now has checked scalar
value-copy helpers with empty-type failures before random-stream use, value
copying, or assertions. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
