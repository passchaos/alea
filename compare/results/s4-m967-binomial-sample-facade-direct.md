# S4-M967 Binomial Sample Facade Direct Paths

## Gap

Scalar `Binomial.sample` and vector `VectorBinomial.sample` facade helpers still
routed through their direct-source `sampleFrom` wrappers. The facade helpers can
execute the same degenerate fast paths and binomial sampling calls directly
through the facade `Rng` while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` binomial workflows sample directly from an RNG
reference. Alea exposes reusable scalar and vector binomial samplers; their
facade `sample` methods should mirror direct RNG-driven sampling without routing
through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates scalar `Binomial.sample` to call
  `binomialFrom(rng, trials, p)` directly.
- `src/distributions.zig` updates `VectorBinomial.sample` to execute degenerate
  zero/all-success fast paths directly and otherwise fill lanes through direct
  binomial sampling from the facade `Rng`.
- Focused tests compare facade and direct-source binomial stream shape for scalar
  and vector helpers.

## Validation

Focused Binomial tests:

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
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M967 is closed for the current bar: Binomial scalar and vector facade samples
now avoid direct-source sample wrapper aliases while preserving stream shape and
degenerate behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
