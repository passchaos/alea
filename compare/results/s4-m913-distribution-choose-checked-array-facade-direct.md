# S4-M913 Distribution Choose Checked Array Facade Direct Paths

## Gap

Distribution-layer `Choose` checked fixed-array facade helpers still routed
through direct-source checked array wrappers. Direct facade checked fills were
already direct, so checked fixed-array helpers can allocate their stack array and
fill it directly while preserving stream shape and checked behavior.

## Local `rand` Baseline

Local Rust `rand` choice workflows fill repeated samples by looping over direct
RNG draws. Alea's distribution-layer `Choose` adds Zig-native fixed-array helpers
for pointer, value, `usize` index, and compact `u32` index outputs. The checked
facade variants should fill the fixed array directly through the facade `Rng`.

## Implementation

- `src/distributions.zig` updates `Choose.ptrArrayChecked` to allocate the fixed
  pointer array and call checked facade pointer fill directly.
- `src/distributions.zig` updates `Choose.valueArrayChecked` to allocate the fixed
  value array and call checked facade value fill directly.
- `src/distributions.zig` updates `Choose.indexArrayChecked` and
  `Choose.indexArrayU32Checked` to allocate fixed index arrays and call checked
  facade index fills directly.
- Focused tests compare each checked facade array helper against the matching
  direct-source checked array helper for stream shape.

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
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M913 is closed for the current bar: distribution-layer `Choose` checked
fixed-array facade helpers now avoid direct-source checked array wrapper aliases
while preserving stream shape and checked behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
