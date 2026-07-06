# S4-M476 Root One-Shot Unicode Scalar Helpers

## Gap

S4-M473 added root one-shot string and Unicode UTF-8 helpers, but root callers
still needed to construct a secure engine for caller-owned or allocation-returning
Unicode scalar range workflows. `Rng` already supports scalar fills, ranges, and
batches; the root API should expose the same common Unicode scalar workflows via
explicit `std.Io` entropy.

## API Added

`src/root.zig` now exposes:

- `unicodeScalarRangeLessThan`
- `unicodeScalarRangeLessThanChecked`
- `unicodeScalarRangeAtMost`
- `unicodeScalarRangeAtMostChecked`
- `fillUnicodeScalar`
- `fillUnicodeScalarRangeLessThan`
- `fillUnicodeScalarRangeLessThanChecked`
- `fillUnicodeScalarRangeAtMost`
- `fillUnicodeScalarRangeAtMostChecked`
- `unicodeScalarBatch`
- `unicodeScalarRangeLessThanBatch`
- `unicodeScalarRangeLessThanBatchChecked`
- `unicodeScalarRangeAtMostBatch`
- `unicodeScalarRangeAtMostBatchChecked`

Zero-length buffers/batches and single-scalar ranges return without drawing
entropy; checked helpers reject invalid non-empty ranges explicitly.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `unicodeScalarFill` and
  `unicodeScalarBatch` in the root string helper output.
- `tools/examplecheck.zig` guards those example tokens.
- `docs/api-reference.md` lists the new root public symbols.
- `compare/results/core-rand-coverage.md`,
  `compare/results/active-goal-completion-audit.md`, and
  `compare/results/linux-no-known-gaps-audit.md` record the milestone and keep
  S4-M11 non-completion explicit.

## Validation

Focused root tests:

```text
$ zig test src/root.zig --test-filter "root random helpers"
1/3 root.test_0...OK
2/3 root.test.root random helpers use explicit system entropy...OK
3/3 root.test.root random helpers validate deterministic cases before entropy...OK
All 3 tests passed.
```

Runnable example and guard checks:

```text
$ zig build run-basic
root string helpers: char=N, string=QTj2UisB, sampleString=Wd6qP1JB, appendString=ZMsFPoIT, unicodeScalar=U+78345, unicodeScalarFill={ 85, 81, 70, 71 }, unicodeScalarBatch={ 66, 66, 68, 85 }, unicodeInto=𮃚򋿽𷸆񪁭, unicodeAlloc=򍳀񄮇򧡸睷
```

```text
$ zig build examplecheck
examplecheck ok
```

```text
$ zig build apicheck
apicheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

Broader native test gate:

```text
$ zig build test
toolingcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

```text
$ git diff --check
```

## Result

S4-M476 is closed for the current bar: root system-entropy callers can fill and
allocate Unicode scalar ranges without manually constructing a secure engine.
This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
