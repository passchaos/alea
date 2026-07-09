# S4-M1054 HalfNormal Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `HalfNormal` facade `sample` / `fill` still routed through
`sampleFrom` / `fillFrom`. The top-level facade helpers already drive facade
`Rng` directly and preserve degenerate `scale == 0` no-consume behavior, so the
reusable samplers can call those helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's HalfNormal surface
is broader than local `rand_distr` with vector fills, but it still follows the
reusable-sampler contract: facade helpers should drive the supplied facade RNG
directly and avoid avoidable wrapper hops.

## Implementation

- `src/distributions.zig` updates `HalfNormal(T).sample` and `HalfNormal(T).fill`
  to call `halfNormal` and `fillHalfNormal` through facade `Rng` directly.
- `src/distributions.zig` updates `VectorHalfNormal(VectorType).sample` and
  `VectorHalfNormal(VectorType).fill` to call vector HalfNormal facade helpers
  directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused HalfNormal tests:

```text
$ zig test src/distributions.zig --test-filter "degenerate half-normal helpers do not consume random stream"
1/2 distributions.test.degenerate half-normal helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length derived distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length derived distribution fills do not validate or consume random stream...OK
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
examplecheck ok
readmecheck ok
```

## Result

S4-M1054 is closed for the current bar: reusable scalar/vector HalfNormal facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
