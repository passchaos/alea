# S4-M808 Distribution Choose Index Fill Direct Uniform Loop

## Gap

S4-M803 optimized distribution-layer `Choose` pointer/value fills, but
`Choose.fillIndicesFrom` still routed every output slot through `sampleIndexFrom`.
That wrapper reloaded length and singleton state per item even though bulk index
fills can cache length once and generate uniform indexes directly.

## Local `rand` Baseline

Rust slice choice workflows generate uniform indexes from a fixed slice length and
map or expose those indexes through iterator workflows. Alea's distribution-layer
`Choose` keeps Zig-native caller-owned index fill helpers; this milestone applies
the same direct uniform-index loop policy to those fills.

## Implementation

- `src/distributions.zig` updates `Choose.fillIndicesFrom` to return immediately
  for empty outputs, cache `items.len` once, preserve singleton no-consumption
  behavior, and fill `usize` indexes with `Rng.uintLessThanFrom` directly.
- Focused tests compare `Choose.fillIndicesFrom` with `Rng.chooseIndexFrom` loops
  under identical seeds, proving stream shape and output mapping stay aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
toolingcheck ok
apicheck ok
```

## Result

S4-M808 is closed for the current bar: distribution-layer `Choose` usize index
fills now avoid per-slot `sampleIndexFrom` wrapper calls and use a direct uniform
index loop while preserving stream shape. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
