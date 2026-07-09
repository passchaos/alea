# S4-M1084 Seq Reservoir Pointer Into Facade Direct Path

## Gap

Top-level sequence `reservoirSamplePtrsInto` still delegated the facade
caller-owned const-pointer reservoir helper through `reservoirSamplePtrsIntoFrom`.
The direct-source helper remains useful for explicit source workflows, but the
facade helper can validate and perform the reservoir pointer replacement loop
directly through facade `Rng`.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes caller-owned const-pointer reservoir output in
addition to value output; this change tightens that facade path without changing
validation, pointer ownership, sample positions, or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSamplePtrsInto` to validate output size and
  call a new facade-only `reservoirSamplePtrsFill` helper.
- `reservoirSamplePtrsIntoFrom` and `reservoirSamplePtrsFillFrom` remain
  unchanged for explicit direct-source workflows.

## Validation

Focused seq reservoir pointer tests:

```text
$ zig test src/seq.zig --test-filter "reservoir pointer buffers preserve stream shape and invalid paths do not consume"
1/2 seq.test.reservoir pointer buffers preserve stream shape and invalid paths do not consume...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "reservoir pointer buffers fill caller-owned reservoir pointer outputs"
1/2 seq.test.reservoir pointer buffers fill caller-owned reservoir pointer outputs...OK
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
readmecheck ok
toolingcheck ok
```

## Result

S4-M1084 is closed for the current bar: sequence `reservoirSamplePtrsInto` now
avoids the direct-source wrapper alias while preserving stream shape,
invalid-count no-consume validation, empty-output behavior, and pointer identity.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
