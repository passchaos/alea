# S4-M875 Pert Reusable Fill Beta Delegate

## Gap

Reusable `Pert.fillFrom` still routed every non-degenerate output through
`Pert.sampleFrom`, adding a wrapper call before drawing the beta-backed value and
affine-mapping it into `[min, max]`.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 represents `Pert` as `{ min, range, beta: Beta<F> }`
and samples with `self.beta.sample(rng) * self.range + self.min`. Alea stores the
same derived alpha/beta and range values, so reusable scalar fills can delegate to
the beta bulk fill once and then affine-map the buffer while preserving the same
stream as repeated `Pert.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Pert.fillFrom` to keep the degenerate
  no-consume path, fill the destination through `fillBetaFrom` using cached PERT
  alpha/beta values, and then apply `min + range * beta_value` in place.
- Focused tests compare f64 and f32 reusable PERT fills with `Pert.sampleFrom`
  loops under identical seeds; existing focused coverage still checks collapsed
  support and infinite-shape no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M875 is closed for the current bar: reusable `Pert.fillFrom` now avoids
per-sample `Pert.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
