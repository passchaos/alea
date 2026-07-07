# S4-M778 Weighted Iterator Choice Exact-Count End-Probe Avoidance

## Gap

S4-M771 handled exact-single weighted iterator choices. For exact-size weighted
iterators with more than one remaining entry, the generic one-shot weighted
choice path still had to discover the end of the iterator with an extra null
probe. Exact remaining information lets Alea read exactly the reported entries
while preserving the existing weighted choice algorithm and stream shape.

## Local `rand` Baseline

The local Rust weighted choice APIs validate weights and use weighted random
selection when multiple positive weights exist. Alea's iterator-specific helpers
can additionally use exact remaining information: exact-size sources are
validated with exactly the known number of reads. Single-positive exact-size
sources still return without entropy; multi-positive exact-size sources preserve
the same random-stream shape as the generic path except that they avoid the
trailing end probe.

## Implementation

- `src/seq.zig` adds `chooseIteratorWeightedExactCountFrom` and routes exact-size
  `chooseIteratorWeightedFrom` through it.
- `src/root.zig` adds `rootChooseIteratorWeightedExactCount` and routes root
  `chooseIteratorWeighted` through it.
- Exact-empty and exact-single behavior remains covered by the exact-count path.
  All-zero sources return `null` / `error.EmptyInput`; invalid weights still
  return `error.InvalidWeight`; multi-positive sources keep generic stream-shape
  parity.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "exact-count weighted iterator choice does not probe past source"
1/2 seq.test.exact-count weighted iterator choice does not probe past source...OK
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
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M778 is closed for the current bar: seq/root weighted iterator one-shot
choices now read exact-size sources exactly for their reported remaining count,
avoiding trailing end probes while preserving exact-single/single-positive
no-entropy behavior and multi-positive stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
