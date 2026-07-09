# S4-M1072 Seq Shuffle Facade Direct Path

## Gap

Top-level sequence `shuffle` still delegated the facade helper through
`shuffleFrom(rng, ...)`. `Rng.shuffle` already exposes the facade path, so the
sequence facade wrapper can call it directly while leaving `shuffleFrom` as the
explicit direct-source helper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for slice shuffling
behavior. Alea's top-level sequence helper remains a Zig-native facade around the
library RNG abstraction; this change tightens the facade path without changing
shuffle semantics or stream shape.

## Implementation

- `src/seq.zig` updates `shuffle` to call `rng.shuffle(T, items)` directly.
- `shuffleFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused seq shuffle tests:

```text
$ zig test src/seq.zig --test-filter "seq shuffle aliases mirror Rng.shuffleFrom"
1/2 seq.test.seq shuffle aliases mirror Rng.shuffleFrom...OK
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
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1072 is closed for the current bar: sequence `shuffle` now avoids the
direct-source wrapper alias while preserving shuffle stream shape and empty /
singleton no-consume behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
