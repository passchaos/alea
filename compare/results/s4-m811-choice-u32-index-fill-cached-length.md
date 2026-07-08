# S4-M811 Choice U32 Index Fill Cached Length Loop

## Gap

S4-M809 optimized reusable `Choice.fillIndicesFrom` for `usize` output. The
compact `u32` fill still checked `self.items.len` repeatedly and cast length
inside the loop setup instead of handling empty output first, caching the item
count once, and then using a direct compact uniform-index loop.

## Local `rand` Baseline

Rust slice choice workflows generate uniform indexes from a fixed slice length.
Alea's reusable `Choice` additionally offers compact `u32` index fills for
populations that fit; this path should use the same fixed-length index stream
with explicit compact-width validation.

## Implementation

- `src/seq.zig` updates `Choice.fillIndicesU32From` to return immediately for
  empty outputs, cache `items.len` once, validate compact width, preserve
  singleton no-consumption behavior, and fill `u32` indexes with
  `Rng.uintLessThanFrom` using the cached `u32` length.
- Focused tests compare `Choice.fillIndicesU32From` with `Rng.chooseIndexU32From`
  loops under identical seeds, proving stream shape and output mapping stay
  aligned.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M811 is closed for the current bar: reusable `Choice` compact `u32` index
fills now use an empty-output precheck and cached-length direct uniform loop
while preserving stream shape and compact width validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
