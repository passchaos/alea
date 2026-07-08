# S4-M966 Bernoulli Fill Facade Direct Paths

## Gap

Scalar `Bernoulli.fill` and vector `VectorBernoulli.fill` facade helpers still
routed through `fillFrom(rng, ...)` wrappers. The facade fills can execute the
same degenerate fast paths, vector fast paths, and threshold loops directly
through the facade `Rng` while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` Bernoulli workflows fill caller-owned buffers by
repeated RNG-driven threshold sampling. Alea exposes reusable scalar and vector
Bernoulli fill helpers; their facade `fill` methods should mirror direct
RNG-driven filling without routing through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates scalar `Bernoulli.fill` to handle always-false,
  always-true, 0.5, and 0.25 fast paths directly through the facade `Rng`, and to
  run direct threshold loops otherwise.
- `src/distributions.zig` updates `VectorBernoulli.fill` to execute vector
  degenerate/fast paths directly through the facade `Rng`, and to fill vector
  lanes with direct threshold comparisons otherwise.
- Focused tests compare facade and direct-source Bernoulli fill stream shape for
  scalar and vector helpers.

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
toolingcheck ok
readmecheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M966 is closed for the current bar: Bernoulli scalar and vector facade fills
now avoid direct-source fill wrapper aliases while preserving stream shape and
degenerate no-consume behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
