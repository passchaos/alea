# S4-M1080 Seq Partial Shuffle Tail Split Checked Facade Direct Path

## Gap

Top-level sequence `partialShuffleTailSplitChecked` still delegated the facade
checked tail-split helper through `partialShuffleTailSplitCheckedFrom(rng, ...)`.
The checked facade can validate the requested count first and then call the
direct `partialShuffleTailSplit` facade path, leaving the `From` helper for
explicit direct-source workflows.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps explicit checked Rust-style tail-selected selected/rest
split helpers; this change tightens the checked tail-split facade without
changing invalid-count validation, tail-selected partition semantics, or stream
shape.

## Implementation

- `src/seq.zig` updates `partialShuffleTailSplitChecked` to reject
  `amount > items.len` before entropy use, then call facade
  `partialShuffleTailSplit(rng, ...)` directly.
- `partialShuffleTailSplitCheckedFrom` remains unchanged for explicit
  direct-source workflows.

## Validation

Focused seq partial-shuffle tests:

```text
$ zig test src/seq.zig --test-filter "partial shuffle and reservoir sample respect counts"
1/2 seq.test.partial shuffle and reservoir sample respect counts...OK
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
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M1080 is closed for the current bar: sequence `partialShuffleTailSplitChecked`
now avoids the direct-source checked wrapper alias while preserving stream shape,
invalid-count no-consume validation, selected-tail/rest-prefix partitioning, and
zero-count no-consume behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
