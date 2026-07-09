# S4-M1082 Seq Reservoir Sample Facade Direct Path

## Gap

Top-level sequence `reservoirSample` still delegated the allocation-returning
facade helper through `reservoirSampleFrom(allocator, rng, ...)`. The
caller-owned facade path now performs reservoir sampling directly, so the owned
facade helper can allocate and fill through that facade path instead of bouncing
through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes allocation-returning reservoir helpers in
addition to caller-owned output; this change tightens the allocation-returning
facade path without changing validation, allocation ownership, sample contents,
or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSample` to allocate the capped output slice and
  fill it through facade `reservoirSampleInto(rng, ...)` directly.
- `reservoirSampleFrom` remains unchanged for explicit direct-source workflows.
- Empty-output and empty-value validation behavior remain unchanged.

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

$ zig test src/seq.zig --test-filter "reservoir value samples validate empty value types before allocation"
1/2 seq.test.reservoir value samples validate empty value types before allocation...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1082 is closed for the current bar: sequence `reservoirSample` now avoids the
direct-source allocation wrapper alias while preserving stream shape, allocation
ownership, empty-output behavior, and empty-value validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
