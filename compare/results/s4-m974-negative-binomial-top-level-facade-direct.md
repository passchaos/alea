# S4-M974 NegativeBinomial Top-Level Facade Direct Paths

## Gap

Top-level scalar NegativeBinomial checked/fill facade helpers still routed through
their `From` wrappers. The reusable `NegativeBinomial` sampler facade paths were
already direct, so top-level facade helpers can validate once and call the facade
sampler or fill directly while preserving stream shape and validation behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` negative-binomial workflows use RNG-reference
entry points for scalar sampling and buffer filling. Alea's top-level facade
helpers should mirror that facade usage without routing through direct-source
wrappers.

## Implementation

- `src/distributions.zig` updates `negativeBinomialChecked` to construct
  `NegativeBinomial` once and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillNegativeBinomial` to construct
  `NegativeBinomial` and call `dist.fill(rng, dest)` directly.
- `src/distributions.zig` updates `fillNegativeBinomialChecked` to preserve
  zero-length no-validation behavior, validate parameters once, and call facade
  fill directly.
- Focused tests cover negative-binomial scalar/vector support and checked error
  behavior.

## Validation

Focused NegativeBinomial tests:

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
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M974 is closed for the current bar: top-level scalar NegativeBinomial
checked/fill facade helpers now avoid direct-source wrapper aliases while
preserving stream shape and validation behavior. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
