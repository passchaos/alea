# S4-M772 Weighted Iterator Sample Exact-Single Allocation Avoidance

## Gap

S4-M771 handled exact-single weighted iterator one-shot choices. Allocation-returning
weighted iterator samples could use the same exact remaining information: a
single entry can be validated and returned (or rejected) without heap setup,
extra end probes, entropy, or random-stream use.

## Local `rand` Baseline

The local Rust weighted iterator sampling APIs use exact iterator size
information where available. Alea can use exact remaining of one to avoid
unnecessary heap and random setup while preserving positive, zero, and invalid
weight semantics.

## Implementation

- `src/seq.zig` handles exact remaining of one in `sampleIteratorWeightedFrom`.
- `src/seq.zig` handles exact remaining of one in `sampleIteratorWeightedCheckedFrom`.
- `src/root.zig` handles exact remaining of one in the root weighted iterator
  allocation helper.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "single exact weighted iterator samples avoid heap allocation"
1/2 seq.test.single exact weighted iterator samples avoid heap allocation...OK
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
examplecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M772 is closed for the current bar: seq/root allocation-returning weighted
iterator samples now resolve exact-single sources without heap setup, extra
probes, entropy, or random-stream use. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
