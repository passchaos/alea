# S4-M1051 Exp2 F32 LogNormal Facade Direct Paths

## Gap

Reusable scalar `LogNormalExp2F32` facade `sample` / `fill` still routed through
`sampleFrom` / `fillFrom`. The exp2-f32 top-level facade helpers already drive
facade `Rng` directly and preserve their snapshot-sensitive output contract, so
the reusable sampler facade can call those helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's exp2-f32
log-normal surface is an explicit opt-in throughput/approximation profile rather
than a Rust API copy. For this gap the relevant comparison is the reusable-sampler
contract: a reusable sampler should drive the provided RNG directly and avoid
avoidable wrapper hops while preserving documented snapshot-sensitive output
mappings.

## Implementation

- `src/distributions.zig` updates `LogNormalExp2F32.sample` to call
  `logNormalExp2F32` through facade `Rng` directly.
- `src/distributions.zig` updates `LogNormalExp2F32.fill` to call
  `fillLogNormalExp2F32` through facade `Rng` directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused exp2-f32 LogNormal test:

```text
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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1051 is closed for the current bar: reusable scalar exp2-f32 LogNormal facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
snapshot-sensitive output semantics. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
