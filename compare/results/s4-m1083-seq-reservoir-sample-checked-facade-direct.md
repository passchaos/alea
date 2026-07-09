# S4-M1083 Seq Reservoir Sample Checked Facade Direct Path

## Gap

Top-level sequence `reservoirSampleChecked` still delegated the checked
allocation-returning facade helper through `reservoirSampleCheckedFrom(allocator,
rng, ...)`. The unchecked allocation-returning facade now allocates and fills
through the direct caller-owned facade path, so the checked facade can validate
first and then call `reservoirSample` directly.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes checked allocation-returning reservoir helpers in
addition to caller-owned output; this change tightens the checked facade path
without changing invalid-count validation, allocation ownership, sample contents,
or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSampleChecked` to reject `amount > items.len`
  before entropy use, preserve empty-value validation, and call facade
  `reservoirSample(allocator, rng, ...)` directly.
- `reservoirSampleCheckedFrom` remains unchanged for explicit direct-source
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
examplecheck ok
toolingcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M1083 is closed for the current bar: sequence `reservoirSampleChecked` now
avoids the direct-source checked allocation wrapper alias while preserving stream
shape, invalid-count no-consume validation, allocation ownership, empty-output
behavior, and empty-value validation. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
