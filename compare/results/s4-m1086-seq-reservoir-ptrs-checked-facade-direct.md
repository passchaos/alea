# S4-M1086 Seq Reservoir Pointer Checked Facade Direct Path

## Gap

Top-level sequence `reservoirSamplePtrsChecked` still delegated the checked
allocation-returning const-pointer reservoir facade through
`reservoirSamplePtrsCheckedFrom(allocator, rng, ...)`. The unchecked
allocation-returning const-pointer facade now allocates and fills through the
direct caller-owned facade path, so the checked facade can validate first and
then call `reservoirSamplePtrs` directly.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for sequence reservoir
sampling behavior. Alea exposes checked allocation-returning const-pointer
reservoir helpers in addition to caller-owned output; this change tightens the
checked facade path without changing invalid-count validation, pointer identity,
allocation ownership, sample positions, or stream shape.

## Implementation

- `src/seq.zig` updates `reservoirSamplePtrsChecked` to reject
  `amount > items.len` before entropy use, then call facade
  `reservoirSamplePtrs(allocator, rng, ...)` directly.
- `reservoirSamplePtrsCheckedFrom` remains unchanged for explicit direct-source
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
apicheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M1086 is closed for the current bar: sequence `reservoirSamplePtrsChecked` now
avoids the direct-source checked allocation wrapper alias while preserving stream
shape, invalid-count no-consume validation, allocation ownership, empty-output
behavior, and pointer identity. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
