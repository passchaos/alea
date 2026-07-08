# S4-M972 Vector Binomial Poisson-Approx Facade Direct Paths

## Gap

Vector Binomial Poisson-approx top-level and reusable facade helpers still routed
through `From` wrappers. The scalar approximation facade was made direct in
S4-M971, so vector facade helpers can validate once and call reusable vector
facade samplers/fills directly while preserving stream shape and approximation
semantics.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` binomial-style workflows use RNG-reference entry
points for sampling. Alea's vector Poisson-approximation binomial helper is an
explicit approximation profile; top-level and reusable vector facades should
avoid direct-source wrapper hops while preserving the documented approximation
behavior.

## Implementation

- `src/distributions.zig` updates `vectorBinomialPoissonApprox` and
  `vectorBinomialPoissonApproxChecked` to construct `VectorBinomialPoissonApprox`
  and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillVectorBinomialPoissonApprox` and
  `fillVectorBinomialPoissonApproxChecked` to construct the reusable sampler and
  call `dist.fill(rng, dest)` directly.
- `src/distributions.zig` updates reusable `VectorBinomialPoissonApprox.sample`
  and `fill` to execute degenerate fast paths and vector lane approximation loops
  directly through the facade `Rng`.
- Focused tests cover vector binomial approximation stream shape and checked
  invalid-probability no-consumption behavior.

## Validation

Focused vector Binomial approximation tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid discrete distribution helpers do not consume random stream"
1/2 distributions.test.invalid discrete distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M972 is closed for the current bar: vector binomial Poisson-approx facade
helpers now avoid direct-source wrapper aliases while preserving approximation
semantics, stream shape, and checked validation behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
