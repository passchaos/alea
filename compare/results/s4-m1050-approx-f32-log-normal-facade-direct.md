# S4-M1050 Approx F32 LogNormal Facade Direct Paths

## Gap

Reusable scalar `LogNormalApproxF32` facade `sample` / `fill` still routed through
`sampleFrom` / `fillFrom`. The approximate-f32 top-level facade helpers already
drive facade `Rng` directly and preserve their snapshot-sensitive output
contract, so the reusable sampler facade can call those helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's approximate
f32 log-normal surface is an explicit opt-in throughput/approximation profile
rather than a Rust API copy. For this gap the relevant comparison is the
reusable-sampler contract: a reusable sampler should drive the provided RNG
directly and avoid avoidable wrapper hops while preserving documented
snapshot-sensitive output mappings.

## Implementation

- `src/distributions.zig` updates `LogNormalApproxF32.sample` to call
  `logNormalApproxF32` through facade `Rng` directly.
- `src/distributions.zig` updates `LogNormalApproxF32.fill` to call
  `fillLogNormalApproxF32` through facade `Rng` directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused approximate/native f32 LogNormal tests:

```text
$ zig test src/distributions.zig --test-filter "native f32 log-normal has stable snapshots"
1/2 distributions.test.native f32 log-normal has stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "native exp2 f32 log-normal has stable snapshots"
1/2 distributions.test.native exp2 f32 log-normal has stable snapshots...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1050 is closed for the current bar: reusable scalar approximate-f32
LogNormal facade sample/fill helpers now avoid direct-source wrapper aliases
while preserving snapshot-sensitive output semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
