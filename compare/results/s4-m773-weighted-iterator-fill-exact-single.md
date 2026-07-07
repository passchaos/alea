# S4-M773 Weighted Iterator Fill Exact-Single Key Avoidance

## Gap

S4-M772 handled exact-single allocation-returning weighted iterator samples.
Caller-owned weighted iterator fills can use the same exact remaining information:
a single entry can be validated and written (or rejected) without key sampling,
extra end probes, entropy, or random-stream use.

## Local `rand` Baseline

The local Rust weighted iterator sampling APIs use exact iterator size
information where available. Alea can use exact remaining of one to avoid
unnecessary weighted-key and random setup while preserving positive, zero, and
invalid weight semantics.

## Implementation

- `src/seq.zig` handles exact remaining of one in `sampleIteratorWeightedIntoFrom`.
- `src/seq.zig` handles exact remaining of one in `sampleIteratorWeightedIntoCheckedFrom`.
- `src/root.zig` handles exact remaining of one in the root weighted iterator
  fill core.

## Validation

Focused sequence/root tests:

```text
$ zig test src/seq.zig --test-filter "single exact weighted iterator fills avoid key sampling"
1/2 seq.test.single exact weighted iterator fills avoid key sampling...OK
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
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M773 is closed for the current bar: seq/root caller-owned weighted iterator
fills now resolve exact-single sources without key sampling, extra probes,
entropy, or random-stream use. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
