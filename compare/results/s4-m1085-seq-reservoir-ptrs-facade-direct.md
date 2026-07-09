# S4-M1085 Seq Reservoir Pointer Facade Direct Path

## Gap

Top-level sequence `reservoirSamplePtrs` still delegated the allocation-returning
facade const-pointer reservoir helper through `reservoirSamplePtrsFrom(allocator,
rng, ...)`. The caller-owned const-pointer facade path now fills directly through
facade `Rng`, so the allocation-returning facade can allocate and fill through
that path instead of bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes allocation-returning const-pointer reservoir
helpers in addition to caller-owned output; this change tightens that facade path
without changing pointer identity, allocation ownership, sample positions, or
stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSamplePtrs` to allocate the capped pointer
  output slice and fill it through facade `reservoirSamplePtrsInto(rng, ...)`
  directly.
- `reservoirSamplePtrsFrom` remains unchanged for explicit direct-source
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
readmecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M1085 is closed for the current bar: sequence `reservoirSamplePtrs` now avoids
the direct-source allocation wrapper alias while preserving stream shape,
allocation ownership, empty-output behavior, and pointer identity. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
