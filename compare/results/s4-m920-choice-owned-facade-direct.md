# S4-M920 Choice Owned Facade Direct Paths

## Gap

Reusable `Choice` allocation-returning facade helpers still routed through
direct-source owned wrappers. Facade fills were already direct, so owned facade
helpers can allocate their output slices and fill them directly while preserving
stream shape and allocation-failure behavior.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows commonly collect repeated samples into
owned containers after direct RNG-driven sampling. Alea's reusable `Choice` adds
allocation-returning pointer, value, `usize` index, and compact `u32` index
helpers. The facade variants should allocate and fill through the facade `Rng`
directly.

## Implementation

- `src/seq.zig` updates `Choice.ptrs` to allocate the pointer slice and call
  facade pointer fill directly.
- `src/seq.zig` updates `Choice.values` to handle zero-length and empty-enum
  prevalidation, allocate the value slice, and call facade value fill directly.
- `src/seq.zig` updates `Choice.indices` and `Choice.indicesU32` to allocate index
  slices and call facade index fills directly.
- Focused tests compare each facade owned helper against the matching direct-source
  owned helper for stream shape.

## Validation

Focused reusable Choice test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M920 is closed for the current bar: reusable `Choice` owned facade helpers now
avoid direct-source owned wrapper aliases while preserving stream shape and
allocation behavior. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
