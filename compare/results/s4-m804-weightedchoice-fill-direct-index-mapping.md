# S4-M804 WeightedChoice Fill Direct Index Mapping

## Gap

S4-M803 optimized unweighted `Choice` / `Choose` pointer and value fills by
mapping generated indexes directly into item storage. Reusable `WeightedChoice`
still routed each pointer/value output through `sampleFrom` / `sampleValueFrom`,
which wrapped an alias-table index sample and then reloaded item storage per slot.

## Local `rand` Baseline

The local Rust checkout (`/home/passchaos/Work/rand/src/seq/slice.rs`) implements
`choose_weighted_iter` by building a `WeightedIndex` over indexes and mapping the
resulting sampled index directly to `&self[i]`. Alea keeps its reusable
`WeightedChoice` sampler and caller-owned fills, but now applies the same direct
index-to-item mapping policy in bulk pointer/value fills.

## Implementation

- `src/seq.zig` updates `WeightedChoice.fillFrom` to cache the item slice and map
  `self.table.sampleFrom(source)` directly to `&items[index]`.
- `src/seq.zig` updates `WeightedChoice.fillValuesFrom` to map alias-table
  indexes directly to copied values.
- Constant-index/single-positive and zero-length output no-consumption behavior
  is preserved.
- Focused tests compare weighted pointer/value fills against weighted index
  fills with identical seeds, proving stream shape and item mapping stay aligned.

## Validation

Focused sequence test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M804 is closed for the current bar: reusable `WeightedChoice` pointer/value
fills now avoid per-slot sample wrapper calls and map alias-table sampled indexes
directly into item storage while preserving weighted stream shape. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
