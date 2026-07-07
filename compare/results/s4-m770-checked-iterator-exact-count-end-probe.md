# S4-M770 Checked Iterator Exact-Count End-Probe Avoidance

## Gap

S4-M768 and S4-M769 avoided extra end-of-iterator probes for unchecked
unweighted iterator samples and caller-owned fills. Checked unweighted iterator
samples could use the same exact remaining information when the requested count
matches the known remaining count.

## Local `rand` Baseline

The local Rust iterator sampling APIs use exact iterator size information where
available. Alea's checked helpers can avoid unnecessary end probes for exact
count matches while preserving checked failure behavior for short sources.

## Implementation

- `src/seq.zig` returns immediately after filling exact-count results in
  `sampleIteratorCheckedFrom`, `sampleIteratorIntoCheckedFrom`, and optional / checked
  fixed-size arrays via `sampleIteratorArrayFrom`.
- `src/root.zig` returns immediately after filling exact-count results in root
  `sampleIteratorChecked`.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "checked iterator samples avoid exact-count end probe"
1/2 seq.test.checked iterator samples avoid exact-count end probe...OK
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
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M770 is closed for the current bar: seq/root checked unweighted iterator
samples now avoid extra end-of-iterator probes for exact-count sources. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
