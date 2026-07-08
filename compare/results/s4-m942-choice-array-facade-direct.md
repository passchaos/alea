# S4-M942 Choice Array Facade Direct Paths

## Gap

Reusable `Choice` non-checked fixed-array facade helpers still routed through
their direct-source array wrappers. The facade fill helpers were already direct,
so fixed-array facades can allocate their stack arrays and fill them directly
while preserving stream shape and validation behavior.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows fill repeated samples by looping over
direct RNG draws. Alea's reusable `Choice` adds Zig-native fixed-array helpers for
pointer, value, `usize` index, and compact `u32` index outputs. The non-checked
facade variants should fill the fixed array directly through the facade `Rng`
instead of routing through direct-source array wrappers.

## Implementation

- `src/seq.zig` updates `Choice.ptrArray` to allocate the fixed pointer array and
  call facade pointer fill directly.
- `src/seq.zig` updates `Choice.valueArray` to allocate the fixed value array and
  call facade value fill directly.
- `src/seq.zig` updates `Choice.indexArray` and `Choice.indexArrayU32` to allocate
  fixed index arrays and call facade index fills directly.
- Focused tests compare facade arrays against direct-source arrays or fill output
  for stream shape, and cover compact-index rejection.

## Validation

Focused reusable Choice tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "Choice owned u32 indices reject oversized population before allocation"
1/3 seq.test.Choice owned u32 indices reject oversized population before allocation...OK
2/3 seq.test.WeightedChoice owned u32 indices reject oversized population before allocation...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M942 is closed for the current bar: reusable `Choice` non-checked fixed-array
facade helpers now avoid direct-source array wrapper aliases while preserving
stream shape and checked compact-index behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
