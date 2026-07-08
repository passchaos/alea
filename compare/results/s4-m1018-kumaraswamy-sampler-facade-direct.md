# S4-M1018 Kumaraswamy Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `Kumaraswamy` facade sample/fill helpers still routed
through `sampleFrom` / `fillFrom` wrappers. The direct-source paths already use
cached method variants for point masses, square-root, one-parameter, and generic
transforms; the facade paths can now do the same through facade `Rng` while
preserving collapsed `alpha == inf` and `beta == inf` point-mass behavior.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while prior Alea
`rand_distr` surface evidence records Kumaraswamy as product-breadth beyond the
locally exposed Rust distribution list. For this gap the relevant comparison is
the reusable-sampler contract: a reusable sampler should drive the provided RNG
directly and avoid avoidable wrapper hops, and Alea should retain its extra
scalar/vector fill and degenerate point-mass semantics.

## Implementation

- `src/distributions.zig` updates `Kumaraswamy(T).sample` and
  `Kumaraswamy(T).fill` to dispatch cached method variants directly through
  facade `Rng`, including point-zero/point-one no-consume fast paths.
- `src/distributions.zig` updates `VectorKumaraswamy(VectorType).sample` and
  `VectorKumaraswamy(VectorType).fill` to draw vector strict-open uniforms
  directly through facade `Rng` and call the matching vector transform helpers,
  with the same point-mass no-consume fast paths.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level helpers.

## Validation

Focused Kumaraswamy tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate kumaraswamy helpers do not consume random stream"
1/2 distributions.test.degenerate kumaraswamy helpers do not consume random stream...OK
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
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M1018 is closed for the current bar: reusable scalar/vector Kumaraswamy facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate point-mass no-consume behavior, and zero-length checked
fill semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
