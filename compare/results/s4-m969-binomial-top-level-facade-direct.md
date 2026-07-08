# S4-M969 Binomial Top-Level Facade Direct Paths

## Gap

Top-level scalar Binomial checked/fill facade helpers still routed through their
`From` wrappers. The reusable `Binomial` sampler facade paths were already
direct, so top-level facade helpers can validate once and call the facade sampler
or fill directly while preserving stream shape and validation behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` binomial workflows use RNG-reference entry
points for scalar sampling and buffer filling. Alea's top-level facade helpers
should mirror that facade usage without routing through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates `binomialChecked` to construct `Binomial` once
  and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillBinomial` to construct `Binomial` and call
  `dist.fill(rng, dest)` directly.
- `src/distributions.zig` updates `fillBinomialChecked` to preserve zero-length
  no-validation behavior, validate parameters once, and call facade fill directly.
- Focused tests cover top-level binomial scalar/fill support and checked error
  behavior.

## Validation

Focused Binomial test:

```text
$ zig test src/distributions.zig --test-filter "basic distributions stay in expected ranges"
1/2 distributions.test.basic distributions stay in expected ranges...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M969 is closed for the current bar: top-level scalar Binomial checked/fill
facade helpers now avoid direct-source wrapper aliases while preserving stream
shape and validation behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
