# S4-M1041 Vector Table Exponential Facade Direct Paths

## Gap

Reusable vector table-quantile Exponential samplers still routed facade `sample` /
`fill` through `sampleFrom` / `fillFrom`. The table-quantile top-level facade
helpers already drive facade `Rng` directly and preserve their explicit
output-mapping contract, so reusable vector table Exponential samplers can call
those facade helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's vector table
Exponential surface is an explicit opt-in throughput profile rather than a Rust
API copy. For this gap the relevant comparison is the reusable-sampler contract:
a reusable sampler should drive the provided RNG directly and avoid avoidable
wrapper hops while preserving documented snapshot-sensitive output mappings.

## Implementation

- `src/distributions.zig` updates `VectorExponentialTableF32.sample` and
  `VectorExponentialTableF32.fill` to call table-exponential facade helpers
  directly and scale by the cached inverse rate.
- `src/distributions.zig` updates `VectorExponentialTableF64.sample` and
  `VectorExponentialTableF64.fill` to call table-exponential facade helpers
  directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused vector table Exponential test:

```text
$ zig test src/distributions.zig --test-filter "vector table exponential has stable snapshots"
1/2 distributions.test.vector table exponential has stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M1041 is closed for the current bar: reusable vector table Exponential facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
snapshot-sensitive output semantics. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
