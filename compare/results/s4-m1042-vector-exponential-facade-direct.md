# S4-M1042 VectorExponential Facade Direct Paths

## Gap

Reusable generic `VectorExponential(VectorType)` facade `sample` / `fill` still
routed through `sampleFrom` / `fillFrom`. The facade vector exponential helpers
already drive facade `Rng` directly and preserve degenerate `rate == inf`
no-consume behavior, so the reusable vector sampler facade can call those helpers
directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's vector exponential
surface is Zig-native, but the reusable-sampler contract is the same: facade
helpers should drive the supplied facade RNG directly and avoid avoidable wrapper
hops.

## Implementation

- `src/distributions.zig` updates `VectorExponential(VectorType).sample` to call
  `vectorStandardExponential` through facade `Rng` directly and scale by the
  cached inverse rate.
- `src/distributions.zig` updates `VectorExponential(VectorType).fill` to call
  `fillVectorStandardExponential` or `fillVectorExponential` through facade
  `Rng` directly, preserving the degenerate no-consume fast path.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused VectorExponential tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate exponential distribution helpers do not consume random stream"
1/2 distributions.test.degenerate exponential distribution helpers do not consume random stream...OK
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
apicheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1042 is closed for the current bar: reusable generic VectorExponential facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
