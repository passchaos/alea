# S4-M968 Binomial Fill Facade Direct Paths

## Gap

Scalar `Binomial.fill` and vector `VectorBinomial.fill` facade helpers still
routed through their direct-source `fillFrom` wrappers. The facade fills can
execute the same degenerate fast paths and binomial sampling loops directly
through the facade `Rng` while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` binomial workflows fill caller-owned buffers by
repeated RNG-driven binomial sampling. Alea exposes reusable scalar and vector
binomial fill helpers; their facade `fill` methods should mirror direct
RNG-driven filling without routing through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates scalar `Binomial.fill` to handle zero/p=0 and
  p=1 fast paths directly, and otherwise fill with direct `binomialFrom(rng, ...)`
  calls.
- `src/distributions.zig` updates `VectorBinomial.fill` to execute degenerate fast
  paths directly and otherwise fill vector lanes with direct binomial sampling
  from the facade `Rng`.
- Focused tests compare facade and direct-source binomial fill stream shape for
  scalar and vector helpers.

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
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M968 is closed for the current bar: Binomial scalar and vector facade fills now
avoid direct-source fill wrapper aliases while preserving stream shape and
degenerate behavior. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
