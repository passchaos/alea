# S4-M1028 InverseGaussian Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `InverseGaussian` facade sample/fill helpers still routed
through `sampleFrom` / `fillFrom` wrappers. The direct-source paths already draw
standard-normal components plus uniform acceptance variates and apply the
Michael-Schucany-Haas transform directly; the facade paths can now do the same
through facade `Rng` while preserving collapsed `mean == 0` and `shape == inf`
point-mass behavior.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline, while Alea's
InverseGaussian coverage intentionally extends the local `rand_distr` surface
with scalar/vector fill and point-mass ergonomics. For this gap the relevant
comparison is the reusable-sampler contract: a reusable sampler should drive the
provided RNG directly and avoid avoidable wrapper hops, and Alea should retain
its extra scalar/vector fill and degenerate point-mass semantics.

## Implementation

- `src/distributions.zig` updates `InverseGaussian(T).sample` and
  `InverseGaussian(T).fill` to draw standard normals and uniform acceptance
  variates directly through facade `Rng`, with no-consume point-mass fast paths.
- `src/distributions.zig` updates `VectorInverseGaussian(VectorType).sample` and
  `VectorInverseGaussian(VectorType).fill` to draw vector standard normals and
  uniform acceptance variates directly through facade `Rng` and call
  `inverseGaussianFromNormalVector`, with the same point-mass no-consume fast
  paths.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level helpers.

## Validation

Focused InverseGaussian tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate inverse-gaussian helpers do not consume random stream"
1/2 distributions.test.degenerate inverse-gaussian helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length inverse and zeta distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length inverse and zeta distribution fills do not validate or consume random stream...OK
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
readmecheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1028 is closed for the current bar: reusable scalar/vector InverseGaussian
facade sample/fill helpers now avoid direct-source wrapper aliases while
preserving stream shape, degenerate point-mass no-consume behavior, and
zero-length checked fill semantics. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
