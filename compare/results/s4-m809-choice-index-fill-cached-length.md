# S4-M809 Choice Index Fill Cached Length Direct Loop

## Gap

S4-M808 optimized distribution-layer `Choose.fillIndicesFrom`. Reusable
`Choice.fillIndicesFrom` already generated uniform indexes directly, but it still
checked `self.items.len` and reloaded the length in the loop expression instead
of handling empty output first and caching the item count once per fill.

## Local `rand` Baseline

Rust slice choice workflows generate uniform indexes from a fixed slice length.
Alea's reusable `Choice` caller-owned index fill should use the same direct
fixed-length index stream while preserving singleton and empty-output
no-consumption behavior.

## Implementation

- `src/seq.zig` updates `Choice.fillIndicesFrom` to return immediately for empty
  outputs, cache `items.len` once, preserve singleton no-consumption behavior,
  and fill `usize` indexes with `Rng.uintLessThanFrom` using the cached length.
- Focused tests compare `Choice.fillIndicesFrom` with `Rng.chooseIndexFrom` loops
  under identical seeds, proving stream shape and output mapping stay aligned.

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
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M809 is closed for the current bar: reusable `Choice` usize index fills now
use an empty-output precheck and cached-length direct uniform loop while
preserving stream shape. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
