# S4-M491 Root One-Shot No-Replacement Index Helpers

## Gap

S4-M490 added no-replacement value sampling, but root callers still needed a
secure engine for no-replacement index sampling (`seq.sampleIndices*`). Index
sampling is the lower-level workflow behind many subset operations and maps
closely to Rust `rand::seq::index` use cases.

## API Added

`src/root.zig` now exposes:

- `sampleIndices`
- `sampleIndicesChecked`
- `sampleIndicesInto`
- `sampleIndicesIntoChecked`
- `sampleIndicesU32`
- `sampleIndicesU32Checked`
- `sampleIndicesU32Into`
- `sampleIndicesU32IntoChecked`

Zero-count outputs and small all-index requests return without drawing entropy.
Checked helpers reject impossible amounts explicitly.

## Adoption and Documentation

- `examples/basic.zig` demonstrates `indices`, `indicesInto`, and `indicesU32`
  in root no-replacement helper output.
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
root no-replacement helpers: sample={ 2, 6, 3 }, indices={ 0, 4, 2 }, indicesInto={ 3, 5, 0 }, indicesU32={ 0, 1, 3 }
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
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
```

```text
$ git diff --check
```

## Result

S4-M491 is closed for the current bar: root system-entropy callers can allocate
or fill no-replacement index samples without manually constructing a secure
engine. This is API ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
