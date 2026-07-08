# S4-M1032 MappedSampler Facade Direct Paths

## Gap

Reusable `MappedSampler` facade `sample` / `fill` helpers still routed through
`sampleFrom` / `fillFrom` wrappers. Mapped samplers are generic adapters over a
base sampler and mapper; their facade paths can drive the base sampler through
facade `Rng` directly and then apply the mapper, matching the reusable-sampler
contract used throughout the distribution namespace.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's mapped
sampler adapter is a Zig-native ergonomic surface rather than a direct Rust API
copy. For this gap the relevant comparison is the reusable-sampler contract: a
reusable sampler adapter should drive the provided RNG directly and avoid
avoidable wrapper hops, without changing the mapped output semantics.

## Implementation

- `src/distributions.zig` updates `MappedSampler.sample` to call
  `rng.sample(In, self.sampler)` directly and apply the mapper.
- `src/distributions.zig` updates `MappedSampler.fill` to draw each mapped value
  through facade `Rng` directly instead of delegating to `fillFrom`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and sample iterator aliases.

## Validation

Focused mapped-sampler test:

```text
$ zig test src/distributions.zig --test-filter "mapped samplers transform reusable sampler outputs"
1/2 distributions.test.mapped samplers transform reusable sampler outputs...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M1032 is closed for the current bar: reusable `MappedSampler` facade sample
and fill helpers now avoid direct-source wrapper aliases while preserving mapped
output semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
