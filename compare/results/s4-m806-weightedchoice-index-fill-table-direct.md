# S4-M806 WeightedChoice Index Fills Reuse AliasTable Direct Paths

## Gap

S4-M805 optimized static `AliasTable` index fills with direct alias-sampling loops.
Reusable `WeightedChoice` still had its own per-slot table sampling loops for
`usize` and compact `u32` index fills. That duplicated wrapper overhead instead
of reusing the freshly optimized static table implementation.

## Local `rand` Baseline

Rust weighted-index workflows center on a weighted-index distribution and sampled
index streams. Alea's reusable `WeightedChoice` wraps an `AliasTable`; index fills
should therefore reuse the table's optimized direct bulk sampling path and keep
the same stream shape as the underlying weighted index sampler.

## Implementation

- `src/seq.zig` updates `WeightedChoice.fillIndicesFrom` to delegate directly to
  `self.table.fillFrom`.
- `src/seq.zig` updates `WeightedChoice.fillIndicesU32From` to prevalidate the
  item count and reuse `self.table.fillU32CheckedFrom`.
- Focused tests compare weighted-choice `usize` and `u32` index fills with the
  underlying table fills under identical seeds, proving stream shape and output
  mapping remain aligned.

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
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M806 is closed for the current bar: reusable `WeightedChoice` index fills now
reuse the optimized `AliasTable` direct fill loops for `usize` and compact `u32`
outputs. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
