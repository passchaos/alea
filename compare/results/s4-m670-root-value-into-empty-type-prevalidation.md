# S4-M670 Root Caller-Owned Value Sample Empty-Type Prevalidation

## Gap

Root fixed-size and allocation-returning no-replacement value helpers now reject
non-zero uninhabited value types before allocation or entropy. Caller-owned value
buffer helpers could still take their deterministic full-count copy path before
validating that the value type is inhabited.

Root caller-owned no-replacement value buffer helpers should reject non-zero empty
enum-containing value types before secure-engine construction and before
deterministic value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes no-replacement slice workflows through
`choose_multiple` and sample/collect patterns. Rust slices cannot contain safe
values of empty enum types, so comparable invalid value-type states are ruled out
before sampling. Alea's Zig-native caller-owned buffers can name empty
enum-containing value types, so `error.EmptyRange` is the deterministic
validation path.

## API Changed

`src/root.zig` now prevalidates empty enum-containing value types in:

- `sampleItemsInto`
- `sampleItemsIntoChecked`

`chooseMultipleInto` and `chooseMultipleIntoChecked` inherit the behavior through
these aliases. The public signatures are unchanged.

Deterministic pre-entropy behavior is explicit:

- Empty output buffers still return immediately before validating the value type.
- Non-empty empty enum-containing value types return `error.EmptyRange` before
  secure-engine construction and before full-count deterministic copying.
- Habitable value types keep existing zero/all/random behavior and stream shape.

## Adoption and Documentation

- Focused root tests cover `sampleItemsInto`, `sampleItemsIntoChecked`,
  `chooseMultipleInto`, and `chooseMultipleIntoChecked` empty-enum failures
  before entropy, while existing zero-output and normal all-items deterministic
  paths remain covered.
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
apicheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M670 is closed for the current bar: root caller-owned no-replacement value
buffer helpers now reject non-zero empty enum-containing value types before
secure-engine construction, deterministic value copying, or assertions. This is
reliability and ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
