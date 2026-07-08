# S4-M970 Vector Binomial Top-Level Facade Direct Paths

## Gap

Top-level vector Binomial facade helpers still routed through their `From`
wrappers. The reusable `VectorBinomial` sampler facade paths were already direct,
so top-level vector facade helpers can validate once and call the facade sampler
or fill directly while preserving stream shape and validation behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` binomial workflows use RNG-reference entry
points for vector-style repeated lane sampling and buffer filling. Alea's
top-level vector facade helpers should mirror that facade usage without routing
through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates `vectorBinomial` and `vectorBinomialChecked` to
  construct `VectorBinomial` once and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillVectorBinomial` and
  `fillVectorBinomialChecked` to construct `VectorBinomial` and call
  `dist.fill(rng, dest)` directly.
- Focused tests cover vector binomial facade/direct stream shape and checked
  error behavior.

## Validation

Focused vector Binomial test:

```text
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
toolingcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M970 is closed for the current bar: top-level vector Binomial facade helpers
now avoid direct-source wrapper aliases while preserving stream shape and checked
validation behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
