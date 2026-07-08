# S4-M957 WeightedChoice Sample Facade Direct Paths

## Gap

Reusable `WeightedChoice.sample` and `WeightedChoice.sampleValue` facade helpers
still routed through `sampleFrom`. The facade helpers can sample the cached
`AliasTable` directly through the facade `Rng` and map to item storage while
preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` weighted-choice workflows sample references or values from a
reusable weighted sampler through an RNG reference. Alea's reusable
`WeightedChoice` should mirror that direct facade workflow without routing
through direct-source wrappers.

## Implementation

- `src/seq.zig` updates `WeightedChoice.sample` to call `self.table.sample(rng)`
  and map the returned index directly to `*const T`.
- `src/seq.zig` updates `WeightedChoice.sampleValue` to call the same direct
  alias-table facade sample and map to a copied value.
- Focused tests compare weighted facade samples/values against direct alias-table
  sampling for stream shape.

## Validation

Focused reusable WeightedChoice test:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
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
apicheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M957 is closed for the current bar: reusable `WeightedChoice.sample` and
`sampleValue` now avoid `sampleFrom` wrapper aliases while preserving stream
shape. This is reliability/ergonomics work only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
