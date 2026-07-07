# S4-M676 Reservoir Value Sample Empty-Type Prevalidation

## Gap

No-replacement value helpers now reject non-zero uninhabited value types across
root, Rng, and seq sample workflows. Reservoir value helpers could still allocate
or copy full-count values for empty enum-containing value types before reaching
impossible value paths.

Reservoir value sampling should reject non-zero empty enum-containing value types
before allocation, entropy, random-stream use, and value copying.

## Local `rand` Baseline

The local Rust `rand` checkout exposes reservoir-style iterator/slice sampling
workflows where impossible value types are ruled out by the type system before
sampling. Alea's Zig-native generic reservoir APIs can name empty
enum-containing value types, so the deterministic validation path is a pre-sample
error (`error.EmptyInput` in `seq`, `error.EmptyRange` in root).

## API Changed

`src/seq.zig` now prevalidates empty enum-containing value types in:

- `reservoirSampleFrom`
- `reservoirSampleCheckedFrom`
- `reservoirSampleIntoFrom`

`src/root.zig` now prevalidates the corresponding root value reservoir wrappers:

- `reservoirSample`
- `reservoirSampleChecked`
- `reservoirSampleIntoChecked` via `reservoirSampleInto`

The public signatures are unchanged.

Deterministic behavior is explicit:

- Zero-count/empty-output requests still return before validating the value type.
- Non-zero empty enum-containing value types return before allocation, entropy,
  random-stream use, or value copying.
- Pointer reservoir helpers are unchanged because they only return addresses into
  caller slices.
- Habitable value types keep existing reservoir behavior and stream shape.

## Adoption and Documentation

- Focused seq tests cover owned and caller-owned reservoir value empty-type
  failures with failing allocators and zero random-stream consumption.
- Focused root tests cover owned and caller-owned root reservoir value empty-type
  failures with failing allocators and no entropy request.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused seq test:

```text
$ zig test src/seq.zig --test-filter "reservoir value samples validate empty value types before allocation"
1/2 seq.test.reservoir value samples validate empty value types before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

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
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M676 is closed for the current bar: reservoir value sampling now rejects
non-zero empty enum-containing value types before allocation, entropy,
random-stream use, value copying, or assertions. This is reliability and
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
