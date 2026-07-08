# S4-M973 NegativeBinomial Sampler Facade Direct Paths

## Gap

Scalar `NegativeBinomial.sample` / `fill` and vector `VectorNegativeBinomial`
facade helpers still routed through their direct-source wrappers. The facade
helpers can execute the same degenerate fast paths and negative-binomial sampling
loops directly through the facade `Rng` while preserving stream shape.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` negative-binomial workflows sample directly from
an RNG reference and fill caller-owned buffers by repeated RNG-driven sampling.
Alea exposes reusable scalar and vector negative-binomial samplers; their facade
methods should avoid direct-source wrapper hops.

## Implementation

- `src/distributions.zig` updates scalar `NegativeBinomial.sample` to call
  `negativeBinomialFrom(rng, successes, p)` directly.
- `src/distributions.zig` updates scalar `NegativeBinomial.fill` to handle p=1
  directly and otherwise fill with direct negative-binomial samples.
- `src/distributions.zig` updates `VectorNegativeBinomial.sample` and `fill` with
  direct degenerate fast paths and lane-wise negative-binomial sampling through
  facade `Rng`.
- Focused tests compare facade and direct-source stream shape for scalar/vector
  negative-binomial helpers and checked invalid-probability behavior.

## Validation

Focused NegativeBinomial tests:

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
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M973 is closed for the current bar: NegativeBinomial scalar and vector facade
samplers/fills now avoid direct-source wrapper aliases while preserving stream
shape and degenerate behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
