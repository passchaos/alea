# S4-M1073 Seq Partial Shuffle Facade Direct Path

## Gap

Top-level sequence `partialShuffle` still delegated the facade helper through
`partialShuffleFrom(rng, ...)`. The direct-source path remains useful for
explicit source workflows, but the facade helper can implement the in-place head
selection directly through facade `Rng`.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps both head-selected and Rust-style tail-selected partial
shuffle helpers; this change tightens the head-selected facade path without
changing the selected prefix semantics or stream shape.

## Implementation

- `src/seq.zig` updates `partialShuffle` to perform the prefix Fisher-Yates loop
  directly with `rng.intRangeLessThan`.
- `partialShuffleFrom` remains unchanged for explicit direct-source workflows.

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
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1073 is closed for the current bar: sequence `partialShuffle` now avoids the
direct-source wrapper alias while preserving stream shape and zero-count
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
