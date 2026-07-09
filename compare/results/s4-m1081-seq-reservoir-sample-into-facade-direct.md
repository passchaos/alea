# S4-M1081 Seq Reservoir Sample Into Facade Direct Path

## Gap

Top-level sequence `reservoirSampleInto` still delegated the facade caller-owned
reservoir sample helper through `reservoirSampleIntoFrom(rng, ...)`. The
direct-source helper remains useful for explicit source workflows, but the facade
helper can validate and perform the reservoir replacement loop directly through
facade `Rng`.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes caller-owned reservoir output in addition to
allocation-returning helpers; this change tightens that facade path without
changing validation, sample contents, or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSampleInto` to perform validation, seed the
  output with the first `out.len` items, and run the reservoir replacement loop
  directly with `rng.uintAtMost`.
- `reservoirSampleIntoFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq reservoir/collection tests:

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
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M1081 is closed for the current bar: sequence `reservoirSampleInto` now avoids
the direct-source wrapper alias while preserving stream shape, invalid-count
no-consume validation, empty-output behavior, and empty-value validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
