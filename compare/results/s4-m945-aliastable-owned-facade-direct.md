# S4-M945 AliasTable Owned Facade Direct Paths

## Gap

Static `AliasTable` allocation-returning facade helpers still routed through
direct-source owned wrappers. Facade fills were already available, so owned
facade helpers can allocate their output slices and fill them directly while
preserving stream shape, allocation-failure behavior, and compact-index
validation.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` weighted-index workflows commonly collect
repeated sampled indexes into owned containers after RNG-driven sampling. Alea's
`AliasTable` adds allocation-returning `usize` and compact `u32` facade helpers;
those facade variants should allocate and fill directly through the facade `Rng`
instead of routing through direct-source owned wrappers.

## Implementation

- `src/distributions.zig` updates `AliasTable.indices` and `indicesChecked` to
  allocate `usize` slices and call facade fills directly.
- `src/distributions.zig` updates `AliasTable.indicesU32` and
  `indicesU32Checked` to keep compact output-size prevalidation, allocate `u32`
  slices, and call facade compact fills directly.
- Focused tests compare facade owned helpers against direct-source owned helpers
  for stream shape and cover oversized compact-index preallocation rejection.

## Validation

Focused AliasTable tests:

```text
$ zig test src/distributions.zig --test-filter "alias table owned index batches mirror fills"
1/2 distributions.test.alias table owned index batches mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "alias table iterators produce repeated indices"
1/2 distributions.test.alias table iterators produce repeated indices...OK
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

S4-M945 is closed for the current bar: static `AliasTable` owned facade helpers
now avoid direct-source owned wrapper aliases while preserving stream shape,
allocation behavior, and checked compact-index behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
