# S4-M975 Vector NegativeBinomial Top-Level Facade Direct Paths

## Gap

Top-level vector NegativeBinomial facade helpers still routed through their
`From` wrappers. The reusable `VectorNegativeBinomial` sampler facade paths were
already direct, so top-level vector facade helpers can validate once and call the
facade sampler or fill directly while preserving stream shape and validation
behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` negative-binomial workflows use RNG-reference
entry points for vector-style repeated lane sampling and buffer filling. Alea's
top-level vector facade helpers should mirror that facade usage without routing
through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates `vectorNegativeBinomial` and
  `vectorNegativeBinomialChecked` to construct `VectorNegativeBinomial` once and
  call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillVectorNegativeBinomial` and
  `fillVectorNegativeBinomialChecked` to construct `VectorNegativeBinomial` and
  call `dist.fill(rng, dest)` directly.
- Focused tests cover vector negative-binomial facade/direct stream shape and
  checked error behavior.

## Validation

Focused vector NegativeBinomial tests:

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
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M975 is closed for the current bar: top-level vector NegativeBinomial facade
helpers now avoid direct-source wrapper aliases while preserving stream shape and
checked validation behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
