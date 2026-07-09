# S4-M1075 Seq Partial Shuffle Split Facade Direct Path

## Gap

Top-level sequence `partialShuffleSplit` still delegated the facade split helper
through `partialShuffleSplitFrom(rng, ...)`. The split facade can reuse the now
direct `partialShuffle` facade path, then construct the selected/rest view
without bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps explicit selected/rest split helpers for head-selected and
Rust-style tail-selected workflows; this change tightens the head-selected split
facade without changing slice partition semantics or stream shape.

## Implementation

- `src/seq.zig` updates `partialShuffleSplit` to call facade
  `partialShuffle(rng, ...)` directly and return selected/rest slices.
- `partialShuffleSplitFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq partial-shuffle tests:

```text
$ zig test src/seq.zig --test-filter "collection sequence helpers preserve direct stream shape"
1/2 seq.test.collection sequence helpers preserve direct stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "partial shuffle and reservoir sample respect counts"
1/2 seq.test.partial shuffle and reservoir sample respect counts...OK
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

S4-M1075 is closed for the current bar: sequence `partialShuffleSplit` now avoids
the direct-source wrapper alias while preserving stream shape, selected/rest
partitioning, and zero-count no-consume behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
