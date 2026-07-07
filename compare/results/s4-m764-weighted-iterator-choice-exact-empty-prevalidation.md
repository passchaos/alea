# S4-M764 Weighted Iterator Choice Exact-Empty Prevalidation

## Gap

S4-M762 and S4-M763 tightened allocation-returning and caller-owned iterator
helpers for exact-empty sources. Weighted iterator one-shot choice helpers could
use the same exact `remaining` / `sizeHint` signal to return no sample before
reading an empty source or setting up entropy/randomness.

## Local `rand` Baseline

The local Rust weighted iterator choice workflows use iterator size information
where available. Alea's weighted one-shot iterator choice helpers can likewise
avoid unnecessary source reads for exact-empty iterators.

## Implementation

- `src/seq.zig` prevalidates exact-empty sources in
  `chooseIteratorWeightedFrom`.
- `src/root.zig` prevalidates exact-empty sources in `chooseIteratorWeighted`.
- Checked variants inherit the no-consumption behavior while returning
  `error.EmptyInput`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "empty exact weighted iterator choice does not read source"
1/2 seq.test.empty exact weighted iterator choice does not read source...OK
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
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M764 is closed for the current bar: seq/root weighted iterator one-shot choice
helpers now return null/errors for exact-empty sources before iterator
consumption, entropy, or random-stream use. This is reliability/validation work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
