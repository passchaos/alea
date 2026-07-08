# S4-M916 Distribution Choose Checked Owned Facade Direct Paths

## Gap

Distribution-layer `Choose` checked allocation-returning facade helpers still
routed through direct-source checked owned wrappers. Checked facade fills were
already direct, so owned facade helpers can allocate their output slices and fill
them directly while preserving stream shape, allocation-failure behavior, and
checked prevalidation.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows commonly collect repeated samples into
owned containers after direct RNG-driven sampling. Alea's distribution-layer
`Choose` adds allocation-returning pointer, value, `usize` index, and compact
`u32` index helpers. The checked facade variants should allocate and fill through
the facade `Rng` directly.

## Implementation

- `src/distributions.zig` updates `Choose.ptrsChecked` to allocate the pointer
  slice and call checked facade pointer fill directly.
- `src/distributions.zig` updates `Choose.valuesChecked` to handle zero-length and
  empty-enum prevalidation, allocate the value slice, and call checked facade
  value fill directly.
- `src/distributions.zig` updates `Choose.indicesChecked` and
  `Choose.indicesU32Checked` to allocate index slices and call checked facade
  index fills directly.
- Focused tests compare each checked facade owned helper against the matching
  direct-source checked owned helper for stream shape.

## Validation

Focused distribution Choose test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M916 is closed for the current bar: distribution-layer `Choose` checked owned
facade helpers now avoid direct-source checked owned wrapper aliases while
preserving stream shape, allocation behavior, and checked behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
