# S4-M810 Distribution Choose U32 Index Fill Cached Length Loop

## Gap

S4-M808 optimized distribution-layer `Choose.fillIndicesFrom` for `usize` output.
The compact `u32` fill still checked `self.items.len` repeatedly and cast length
inside the loop expression instead of handling empty output first, caching the
item count once, and then using a direct compact uniform-index loop.

## Local `rand` Baseline

Rust slice choice workflows generate uniform indexes from a fixed slice length.
Alea's distribution-layer `Choose` additionally offers compact `u32` index fills
for populations that fit; this path should use the same fixed-length index stream
with explicit compact-width validation.

## Implementation

- `src/distributions.zig` updates `Choose.fillIndicesU32From` to return
  immediately for empty outputs, cache `items.len` once, validate compact width,
  preserve singleton no-consumption behavior, and fill `u32` indexes with
  `Rng.uintLessThanFrom` using the cached `u32` length.
- Focused tests compare `Choose.fillIndicesU32From` with `Rng.chooseIndexU32From`
  loops under identical seeds, proving stream shape and output mapping stay
  aligned.

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
toolingcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M810 is closed for the current bar: distribution-layer `Choose` compact `u32`
index fills now use an empty-output precheck and cached-length direct uniform
loop while preserving stream shape and compact width validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
