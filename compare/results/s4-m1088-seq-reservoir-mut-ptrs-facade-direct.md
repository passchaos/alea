# S4-M1088 Seq Reservoir Mutable Pointer Facade Direct Path

## Gap

Top-level sequence `reservoirSampleMutPtrs` still delegated the allocation-returning
facade mutable-pointer reservoir helper through `reservoirSampleMutPtrsFrom(allocator,
rng, ...)`. The caller-owned mutable-pointer facade path now fills directly
through facade `Rng`, so the allocation-returning facade can allocate and fill
through that path instead of bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes allocation-returning mutable-pointer reservoir
helpers in addition to caller-owned output; this change tightens that facade path
without changing pointer identity, allocation ownership, sample positions, or
stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSampleMutPtrs` to allocate the capped mutable
  pointer output slice and fill it through facade `reservoirSampleMutPtrsInto(rng,
  ...)` directly.
- `reservoirSampleMutPtrsFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq reservoir pointer tests:

```text
$ zig test src/seq.zig --test-filter "reservoir pointer slices preserve stream shape and invalid paths do not consume"
1/2 seq.test.reservoir pointer slices preserve stream shape and invalid paths do not consume...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "reservoir pointer slices allocate reservoir pointer samples"
1/2 seq.test.reservoir pointer slices allocate reservoir pointer samples...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "reservoir pointer buffers preserve stream shape and invalid paths do not consume"
1/2 seq.test.reservoir pointer buffers preserve stream shape and invalid paths do not consume...OK
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
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1088 is closed for the current bar: sequence `reservoirSampleMutPtrs` now
avoids the direct-source allocation wrapper alias while preserving stream shape,
allocation ownership, empty-output behavior, and mutable pointer identity. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
