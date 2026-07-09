# S4-M1049 VectorLogNormal Facade Direct Paths

## Gap

Reusable generic `VectorLogNormal(VectorType)` facade `sample` / `fill` still
routed through `sampleFrom` / `fillFrom`. The facade vector log-normal helpers
already drive facade `Rng` directly and preserve degenerate `stddev == 0`
no-consume behavior, so the reusable vector sampler facade can call those helpers
directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's vector log-normal
surface is Zig-native, but the reusable-sampler contract is the same: facade
helpers should drive the supplied facade RNG directly and avoid avoidable wrapper
hops.

## Implementation

- `src/distributions.zig` updates `VectorLogNormal(VectorType).sample` to call
  `vectorLogNormal` through facade `Rng` directly.
- `src/distributions.zig` updates `VectorLogNormal(VectorType).fill` to call
  `fillVectorLogNormal` through facade `Rng` directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused VectorLogNormal tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate normal and log-normal helpers do not consume random stream"
1/2 distributions.test.degenerate normal and log-normal helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length distribution vector fills do not validate or consume random stream"
1/2 distributions.test.zero-length distribution vector fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M1049 is closed for the current bar: reusable generic VectorLogNormal facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
