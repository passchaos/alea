# S4-M669 Root Fixed Value Array Empty-Type Prevalidation

## Gap

Root no-replacement value allocation helpers already reject non-zero uninhabited
value types before allocation and entropy. Fixed-size no-replacement value array
helpers could still take their deterministic full-count branch and copy values
before validating that the value type is inhabited.

Root fixed-size value array helpers should reject non-zero empty enum-containing
value types before secure-engine construction and before deterministic value
copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes fixed-size no-replacement slice sampling
through sample-array style workflows. Rust slices cannot contain safe values of
empty enum types, so comparable invalid value-type states are ruled out before
sampling. Alea's Zig-native generic API can name empty enum-containing value
types, so `error.EmptyRange` is the deterministic validation path.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `sampleItemsArray`
- `sampleItemsArrayChecked`

`chooseArray` and `chooseArrayChecked` inherit the behavior through these aliases.
The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Zero-size arrays still return immediately before validating the value type.
- Non-zero empty enum-containing value types return `error.EmptyRange` before
  secure-engine construction and before full-count deterministic copying.
- Habitable value types keep existing zero/all/random behavior and stream shape.

## Adoption and Documentation

- Focused root tests cover `sampleItemsArray`, `sampleItemsArrayChecked`,
  `chooseArray`, and `chooseArrayChecked` empty-enum failures before entropy,
  while existing zero-size and normal all-items deterministic paths remain
  covered.
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
roadmapcheck ok
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M669 is closed for the current bar: root fixed-size no-replacement value array
helpers now reject non-zero empty enum-containing value types before
secure-engine construction, deterministic value copying, or assertions. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
