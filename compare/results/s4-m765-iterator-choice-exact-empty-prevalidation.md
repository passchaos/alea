# S4-M765 Iterator Choice Exact-Empty Prevalidation

## Gap

S4-M764 tightened weighted iterator one-shot choice helpers for exact-empty
sources. The unweighted one-shot iterator choice helpers could use the same exact
`remaining` / `sizeHint` signal to return no sample before reading an empty
source or setting up entropy/randomness.

## Local `rand` Baseline

The local Rust iterator choice workflows use iterator size information where
available. Alea's unweighted one-shot iterator choice helpers can likewise avoid
unnecessary source reads for exact-empty iterators.

## Implementation

- `src/seq.zig` prevalidates exact-empty sources in `chooseIteratorFrom`.
- `src/root.zig` prevalidates exact-empty sources in `rootChooseIterator`, so
  root `chooseIterator` / checked / stable paths inherit the no-consumption
  behavior.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "empty exact iterator choice does not read source"
1/2 seq.test.empty exact iterator choice does not read source...OK
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
examplecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M765 is closed for the current bar: seq/root unweighted iterator one-shot
choice helpers now return null/errors for exact-empty sources before iterator
consumption, entropy, or random-stream use. This is reliability/validation work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
