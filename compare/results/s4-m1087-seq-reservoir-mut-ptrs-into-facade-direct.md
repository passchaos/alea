# S4-M1087 Seq Reservoir Mutable Pointer Into Facade Direct Path

## Gap

Top-level sequence `reservoirSampleMutPtrsInto` still delegated the facade
caller-owned mutable-pointer reservoir helper through `reservoirSampleMutPtrsIntoFrom`.
The direct-source helper remains useful for explicit source workflows, but the
facade helper can validate and perform the mutable-pointer reservoir replacement
loop directly through facade `Rng`.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes caller-owned mutable-pointer reservoir output in
addition to const-pointer output; this change tightens that facade path without
changing validation, pointer ownership, sample positions, or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSampleMutPtrsInto` to validate output size and
  call a new facade-only `reservoirSampleMutPtrsFill` helper.
- `reservoirSampleMutPtrsIntoFrom` and `reservoirSampleMutPtrsFillFrom` remain
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
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1087 is closed for the current bar: sequence `reservoirSampleMutPtrsInto` now
avoids the direct-source wrapper alias while preserving stream shape,
invalid-count no-consume validation, empty-output behavior, and mutable pointer
identity. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
