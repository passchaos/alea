# S4-M1089 Seq Reservoir Mutable Pointer Checked Facade Direct Path

## Gap

Top-level sequence `reservoirSampleMutPtrsChecked` still delegated the checked
allocation-returning mutable-pointer reservoir facade through
`reservoirSampleMutPtrsCheckedFrom(allocator, rng, ...)`. The unchecked
allocation-returning mutable-pointer facade now allocates and fills through the
direct caller-owned facade path, so the checked facade can validate first and
then call `reservoirSampleMutPtrs` directly.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes checked allocation-returning mutable-pointer
reservoir helpers in addition to caller-owned output; this change tightens the
checked facade path without changing invalid-count validation, pointer identity,
allocation ownership, sample positions, or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSampleMutPtrsChecked` to reject
  `amount > items.len` before entropy use, then call facade
  `reservoirSampleMutPtrs(allocator, rng, ...)` directly.
- `reservoirSampleMutPtrsCheckedFrom` remains unchanged for explicit
  direct-source workflows.

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
roadmapcheck ok
apicheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M1089 is closed for the current bar: sequence `reservoirSampleMutPtrsChecked`
now avoids the direct-source checked allocation wrapper alias while preserving
stream shape, invalid-count no-consume validation, allocation ownership,
empty-output behavior, and mutable pointer identity. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
