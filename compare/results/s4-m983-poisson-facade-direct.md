# S4-M983 Poisson Facade Direct Paths

## Gap

Top-level scalar/vector `Poisson` facade helpers and reusable scalar/vector
`Poisson` facade sample/fill methods still routed through their `From` wrappers.
S4-M981 and S4-M982 made the Ahrens-Dieter vector-specific facade paths direct;
the general Poisson facade can now dispatch directly to the selected zero,
product, or Ahrens-Dieter method through the facade `Rng` while preserving stream
shape and zero-length checked-fill behavior.

## Local `rand` Baseline

Local Rust `rand_distr 0.6.0` Poisson sampling dispatches through
`Distribution::sample(&mut rng)`: zero is rejected at construction, small lambdas
use the Knuth/product method, and large lambdas use Ahrens-Dieter rejection from
the supplied RNG reference. Alea supports an additional deterministic zero-lambda
point mass, but non-zero scalar/vector facade helpers should still sample from
the facade RNG directly instead of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates top-level `poisson`, `poissonChecked`,
  `fillPoisson`, and `fillPoissonChecked` to construct `Poisson` once and call
  reusable facade `sample` / `fill` directly.
- `src/distributions.zig` updates top-level `vectorPoisson`,
  `vectorPoissonChecked`, `fillVectorPoisson`, and `fillVectorPoissonChecked` to
  construct `VectorPoisson` once and call reusable facade `sample` / `fill`
  directly.
- Reusable `Poisson.sample`, `Poisson.fill`, `VectorPoisson.sample`, and
  `VectorPoisson.fill` now dispatch directly to zero/product/Ahrens-Dieter method
  bodies through facade `Rng`, instead of delegating to `sampleFrom` / `fillFrom`.
- Checked fill facades keep the existing zero-length fast path so empty
  destinations neither validate `lambda` nor consume random input.

## Validation

Focused Poisson tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution facade misc scalars do not consume random stream"
1/2 distributions.test.invalid distribution facade misc scalars do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution vector helpers do not consume random stream"
1/2 distributions.test.invalid distribution vector helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length discrete distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length discrete distribution fills do not validate or consume random stream...OK
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
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M983 is closed for the current bar: general scalar/vector Poisson facade
helpers now avoid direct-source wrapper aliases while preserving stream shape,
zero-lambda no-consume behavior, and checked validation behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
