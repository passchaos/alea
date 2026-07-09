# S4-M1078 Seq Partial Shuffle Tail Checked Facade Direct Path

## Gap

Top-level sequence `partialShuffleTailChecked` still delegated the facade checked
tail helper through `partialShuffleTailCheckedFrom(rng, ...)`. The checked tail
facade can validate the requested count first and then call the direct
`partialShuffleTail` facade path, leaving the `From` helper for explicit
direct-source workflows.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for partial shuffle
behavior. Alea keeps explicit checked Rust-style tail-selected helpers; this
change tightens the checked tail facade without changing invalid-count
validation, tail-selected semantics, or stream shape.

## Implementation

- `src/seq.zig` updates `partialShuffleTailChecked` to reject
  `amount > items.len` before entropy use, then call facade
  `partialShuffleTail(rng, ...)` directly.
- `partialShuffleTailCheckedFrom` remains unchanged for explicit direct-source
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
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1078 is closed for the current bar: sequence `partialShuffleTailChecked` now
avoids the direct-source checked wrapper alias while preserving stream shape,
invalid-count no-consume validation, tail-selected semantics, and zero-count
no-consume behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
