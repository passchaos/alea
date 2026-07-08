# S4-M835 Exponential Reusable Fill Stages Standard Samples Once

## Gap

Top-level exponential fill helpers already share standard-exponential bulk
sampling and parameter scaling. Reusable `Exponential.fillFrom` still looped
through `Exponential.sampleFrom`, adding a reusable-sampler wrapper call and rate
branch for every output instead of staging standard exponential samples once and
scaling the destination buffer.

## Local `rand_distr` Baseline

Local `rand_distr` implements `Exp<F>` as `Exp1 * lambda_inverse`, with `Exp1`
being the optimized primitive. Alea's reusable exponential fill can follow the
same decomposition in bulk form: fill standard exponential values through the
shared helper, then apply the cached inverse rate while preserving the same
sample stream as repeated `sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Exponential.fillFrom` to keep the existing
  infinite-rate degenerate no-consume path, then call
  `fillStandardExponentialFrom(source, T, dest)` and scale in place by
  `self.inverse_rate` when needed.
- Focused tests compare reusable f64 and f32 fills with scalar
  `Exponential.sampleFrom` loops under identical seeds, proving output values
  and stream position stay aligned. The focused test also covers infinite-rate
  no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M835 is closed for the current bar: reusable `Exponential.fillFrom` now avoids
per-item `Exponential.sampleFrom` wrapper calls for non-degenerate distributions
while preserving stream shape and degenerate no-consume behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
