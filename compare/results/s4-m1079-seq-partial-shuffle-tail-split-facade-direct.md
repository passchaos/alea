# S4-M1079 Seq Partial Shuffle Tail Split Facade Direct Path

## Gap

Top-level sequence `partialShuffleTailSplit` still delegated the facade tail-split
helper through `partialShuffleTailSplitFrom(rng, ...)`. The direct-source path
remains useful for explicit source workflows, but the facade helper can reuse the
now-direct `partialShuffleTail` facade path and construct the selected/rest view
without routing through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps Rust-style tail-selected selected/rest split helpers; this
change tightens the tail-split facade path without changing selected-tail /
rest-prefix semantics or stream shape.

## Implementation

- `src/seq.zig` updates `partialShuffleTailSplit` to call facade
  `partialShuffleTail(rng, ...)` directly and return selected/rest slices.
- `partialShuffleTailSplitFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq partial-shuffle tests:

```text
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

S4-M1079 is closed for the current bar: sequence `partialShuffleTailSplit` now
avoids the direct-source wrapper alias while preserving stream shape,
selected-tail/rest-prefix partitioning, and zero-count no-consume behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
