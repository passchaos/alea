# S4-M915 WeightedChoice Checked Array Facade Direct Paths

## Gap

Reusable `WeightedChoice` checked fixed-array facade helpers still routed through
direct-source checked array wrappers. Direct facade checked fills were already
direct, so checked fixed-array helpers can allocate their stack array and fill it
directly while preserving stream shape and checked behavior.

## Local `rand` Baseline

Local Rust `rand` weighted-choice workflows fill repeated samples by looping over
direct RNG draws from a reusable weighted sampler. Alea's reusable `WeightedChoice`
adds Zig-native fixed-array helpers for pointer, value, `usize` index, and compact
`u32` index outputs. The checked facade variants should fill the fixed array
directly through the facade `Rng` and cached alias table.

## Implementation

- `src/seq.zig` updates `WeightedChoice.ptrArrayChecked` to allocate the fixed
  pointer array and call checked facade pointer fill directly.
- `src/seq.zig` updates `WeightedChoice.valueArrayChecked` to allocate the fixed
  value array and call checked facade value fill directly.
- `src/seq.zig` updates `WeightedChoice.indexArrayChecked` and
  `WeightedChoice.indexArrayU32Checked` to allocate fixed index arrays and call
  checked facade index fills directly.
- Focused tests compare each checked facade array helper against the matching
  direct-source checked array helper for stream shape.

## Validation

Focused reusable WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "WeightedChoice index arrays mirror fills"
1/2 seq.test.WeightedChoice index arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "WeightedChoice value and pointer arrays mirror fills"
1/2 seq.test.WeightedChoice value and pointer arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M915 is closed for the current bar: reusable `WeightedChoice` checked
fixed-array facade helpers now avoid direct-source checked array wrapper aliases
while preserving stream shape and checked behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
