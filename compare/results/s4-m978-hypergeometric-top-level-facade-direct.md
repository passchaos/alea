# S4-M978 Hypergeometric Top-Level Facade Direct Paths

## Gap

Top-level scalar Hypergeometric facade helpers still routed through their `From`
wrappers. The reusable `Hypergeometric` sampler facade paths were already direct,
so top-level facade helpers can validate once and call the facade sampler or fill
directly while preserving stream shape and validation behavior.

## Local `rand` Baseline

Local Rust `rand_distr` hypergeometric workflows use RNG-reference entry points
for scalar sampling and buffer filling. Alea's top-level facade helpers should
mirror that facade usage without routing through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates `hypergeometric` and `hypergeometricChecked` to
  construct `Hypergeometric` once and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillHypergeometric` and
  `fillHypergeometricChecked` to construct `Hypergeometric` and call
  `dist.fill(rng, dest)` directly.
- Focused tests cover scalar hypergeometric support and checked error behavior.

## Validation

Focused Hypergeometric tests:

```text
$ zig test src/distributions.zig --test-filter "negative-binomial and hypergeometric samplers have plausible moments"
1/2 distributions.test.negative-binomial and hypergeometric samplers have plausible moments...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid scalar distribution helpers do not consume random stream"
1/2 distributions.test.invalid scalar distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M978 is closed for the current bar: top-level scalar Hypergeometric facade
helpers now avoid direct-source wrapper aliases while preserving stream shape and
checked validation behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
