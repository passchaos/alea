# S4-M971 Binomial Poisson-Approx Facade Direct Paths

## Gap

Top-level scalar `binomialPoissonApprox` and `binomialPoissonApproxChecked`
facade helpers still routed through their `From` wrappers. These helpers can
execute the same degenerate fast paths, probability mirroring, Poisson sampling,
and checked validation directly through the facade `Rng` while preserving stream
shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` binomial-style workflows use RNG-reference entry
points for scalar sampling. Alea's Poisson-approximation binomial helper is an
explicit approximation profile; its top-level facade should avoid direct-source
wrapper hops while preserving the documented approximation behavior.

## Implementation

- `src/distributions.zig` updates `binomialPoissonApprox` to assert probability
  preconditions, handle degenerate cases, mirror probabilities above 0.5, sample
  Poisson directly through the facade `Rng`, and map the result back.
- `src/distributions.zig` updates `binomialPoissonApproxChecked` to validate
  probability once and call the direct facade sampler.
- Focused tests cover checked invalid-probability no-consumption behavior and
  vector/binomial approximation support.

## Validation

Focused Binomial approximation tests:

```text
$ zig test src/distributions.zig --test-filter "invalid discrete distribution helpers do not consume random stream"
1/2 distributions.test.invalid discrete distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M971 is closed for the current bar: scalar binomial Poisson-approx facade
helpers now avoid direct-source wrapper aliases while preserving approximation
semantics, stream shape, and checked validation behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
