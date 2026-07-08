# S4-M965 Bernoulli Sample Facade Direct Paths

## Gap

Scalar `Bernoulli.sample` and vector `VectorBernoulli.sample` facade helpers still
routed through their direct-source `sampleFrom` wrappers. Both facade helpers can
execute the same degenerate fast paths and RNG threshold comparisons directly
through the facade `Rng` while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` Bernoulli workflows sample directly from an RNG
reference. Alea exposes reusable scalar and vector Bernoulli samplers; their
facade `sample` methods should mirror direct RNG-driven sampling without routing
through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates scalar `Bernoulli.sample` to handle always-false
  and always-true cases without consuming randomness, otherwise compare
  `Rng.nextFrom(rng)` directly against the stored threshold.
- `src/distributions.zig` updates `VectorBernoulli.sample` to execute vector
  fast paths for 0, 1, 0.5, and 0.25 probabilities directly through the facade
  `Rng`, and otherwise fill lanes with direct threshold comparisons.
- Focused tests compare facade and direct-source Bernoulli stream shape for scalar
  and vector helpers.

## Validation

Focused Bernoulli tests:

```text
$ zig test src/distributions.zig --test-filter "basic distributions stay in expected ranges"
1/2 distributions.test.basic distributions stay in expected ranges...OK
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
roadmapcheck ok
readmecheck ok
apicheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M965 is closed for the current bar: Bernoulli scalar and vector facade samples
now avoid direct-source sample wrapper aliases while preserving stream shape and
degenerate no-consume behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
