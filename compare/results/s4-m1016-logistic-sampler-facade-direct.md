# S4-M1016 Logistic Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `Logistic` facade sample/fill helpers still routed through
`sampleFrom` / `fillFrom` wrappers. The direct-source paths already draw
strict-open uniforms and apply the Logistic logit transform directly; the facade
paths can now do the same through facade `Rng` while preserving collapsed
`scale == 0` point-mass behavior.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while prior Alea
`rand_distr` surface evidence records Logistic as product-breadth beyond the
locally exposed Rust distribution list. For this gap the relevant comparison is
the reusable-sampler contract: a reusable sampler should drive the provided RNG
directly and avoid avoidable wrapper hops, and Alea should retain its extra
scalar/vector fill and degenerate point-mass semantics.

## Implementation

- `src/distributions.zig` updates `Logistic(T).sample` and `Logistic(T).fill` to
  draw strict-open uniforms directly through facade `Rng` and apply the stable
  logit transform, with a `scale == 0` no-consume fast path.
- `src/distributions.zig` updates `VectorLogistic(VectorType).sample` and
  `VectorLogistic(VectorType).fill` to draw vector strict-open uniforms directly
  through facade `Rng` and call `logisticFromOpenUniformVector`, with the same
  point-mass no-consume fast path.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level helpers.

## Validation

Focused Logistic tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate laplace and logistic helpers do not consume random stream"
1/2 distributions.test.degenerate laplace and logistic helpers do not consume random stream...OK
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
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M1016 is closed for the current bar: reusable scalar/vector Logistic facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate point-mass no-consume behavior, and zero-length checked
fill semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
