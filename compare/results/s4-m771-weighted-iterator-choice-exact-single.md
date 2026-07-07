# S4-M771 Weighted Iterator Choice Exact-Single End-Probe Avoidance

## Gap

S4-M764 handled exact-empty weighted iterator choices. Exact-single sources can
also be resolved deterministically after reading and validating the single entry:
positive weight returns the item, zero weight returns no sample, and invalid
weight returns `InvalidWeight`. No second `next()` probe or randomness is needed.

## Local `rand` Baseline

The local Rust weighted iterator choice workflows use iterator size information
where available. Alea can use exact remaining of one to avoid unnecessary end
probes while preserving weight validation semantics.

## Implementation

- `src/seq.zig` handles exact remaining of one in `chooseIteratorWeightedFrom`.
- `src/root.zig` handles exact remaining of one in root `chooseIteratorWeighted`.
- Checked variants inherit the behavior and translate zero-positive exact-single
  sources to `error.EmptyInput`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "single exact weighted iterator choice does not probe past source"
1/2 seq.test.single exact weighted iterator choice does not probe past source...OK
2/2 root.test_0...OK
All 2 tests passed.
```

```text
$ zig test src/root.zig --test-filter "root random helpers validate deterministic cases before entropy"
1/2 root.test_0...OK
2/2 root.test.root random helpers validate deterministic cases before entropy...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M771 is closed for the current bar: seq/root weighted iterator one-shot choice
helpers now resolve exact-single sources without an extra end probe or randomness.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
