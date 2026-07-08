# S4-M921 WeightedChoice Owned Facade Direct Paths

## Gap

Reusable `WeightedChoice` allocation-returning facade helpers still routed through
direct-source owned wrappers. Facade fills were already direct, so owned facade
helpers can allocate their output slices and fill them directly while preserving
stream shape and allocation-failure behavior.

## Local `rand` Baseline

Local Rust `rand` weighted-choice workflows commonly collect repeated samples into
owned containers after direct RNG-driven sampling from a reusable weighted
sampler. Alea's reusable `WeightedChoice` adds allocation-returning pointer,
value, `usize` index, and compact `u32` index helpers. The facade variants should
allocate and fill through the facade `Rng` and cached alias table directly.

## Implementation

- `src/seq.zig` updates `WeightedChoice.ptrs` to allocate the pointer slice and
  call facade pointer fill directly.
- `src/seq.zig` updates `WeightedChoice.values` to handle zero-length and
  empty-enum prevalidation, allocate the value slice, and call facade value fill
  directly.
- `src/seq.zig` updates `WeightedChoice.indices` and `WeightedChoice.indicesU32`
  to allocate index slices and call facade index fills directly.
- Focused tests compare each facade owned helper against the matching direct-source
  owned helper for stream shape.

## Validation

Focused reusable WeightedChoice test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M921 is closed for the current bar: reusable `WeightedChoice` owned facade
helpers now avoid direct-source owned wrapper aliases while preserving stream
shape and allocation behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
