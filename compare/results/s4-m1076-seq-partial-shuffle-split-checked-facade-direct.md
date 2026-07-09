# S4-M1076 Seq Partial Shuffle Split Checked Facade Direct Path

## Gap

Top-level sequence `partialShuffleSplitChecked` still delegated the facade checked
split helper through `partialShuffleSplitCheckedFrom(rng, ...)`. The checked split
facade can validate the requested count first and then call the direct
`partialShuffleSplit` facade path, leaving the `From` helper for explicit
direct-source workflows.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps explicit checked selected/rest split helpers for
head-selected and Rust-style tail-selected workflows; this change tightens the
checked head-split facade without changing invalid-count validation, partition
semantics, or stream shape.

## Implementation

- `src/seq.zig` updates `partialShuffleSplitChecked` to reject
  `amount > items.len` before entropy use, then call facade
  `partialShuffleSplit(rng, ...)` directly.
- `partialShuffleSplitCheckedFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq partial-shuffle tests:

```text
$ zig test src/seq.zig --test-filter "collection sequence helpers preserve direct stream shape"
1/2 seq.test.collection sequence helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "invalid facade collection helpers do not consume random stream"
1/2 seq.test.invalid facade collection helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "zero-count partial shuffle does not mutate or consume random stream"
1/2 seq.test.zero-count partial shuffle does not mutate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M1076 is closed for the current bar: sequence `partialShuffleSplitChecked` now
avoids the direct-source checked wrapper alias while preserving stream shape,
invalid-count no-consume validation, selected/rest partitioning, and zero-count
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
