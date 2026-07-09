# S4-M1074 Seq Partial Shuffle Checked Facade Direct Path

## Gap

Top-level sequence `partialShuffleChecked` still delegated the facade checked
helper through `partialShuffleCheckedFrom(rng, ...)`. The checked facade can
perform validation first and then call the direct `partialShuffle` facade path,
leaving `partialShuffleCheckedFrom` for explicit direct-source workflows.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps explicit checked helpers for invalid-count validation; this
change tightens the checked facade path without changing validation,
head-selected semantics, or stream shape.

## Implementation

- `src/seq.zig` updates `partialShuffleChecked` to reject `amount > items.len`
  before entropy use, then call facade `partialShuffle(rng, ...)` directly.
- `partialShuffleCheckedFrom` remains unchanged for explicit direct-source
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
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1074 is closed for the current bar: sequence `partialShuffleChecked` now
avoids the direct-source checked wrapper alias while preserving stream shape,
invalid-count no-consume validation, and zero-count no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
