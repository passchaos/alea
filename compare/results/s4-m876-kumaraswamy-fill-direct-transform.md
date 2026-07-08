# S4-M876 Kumaraswamy Reusable Fill Direct Transform

## Gap

Reusable `Kumaraswamy.fillFrom` already had point-mass and one-parameter edge
paths, but the remaining generic path still routed every output through
`Kumaraswamy.sampleFrom`, adding a wrapper call before drawing an open-uniform
value and applying the Kumaraswamy inverse-CDF transform.

## Local `rand_distr` Baseline

The local `rand_distr` 0.6.0 checkout does not expose a Kumaraswamy sampler, so
Alea's reusable `Kumaraswamy` remains a parity-plus bounded-shape distribution.
For this distribution Alea's generic sampler is the inverse-CDF composition
`(1 - (1 - U)^(1/beta))^(1/alpha)`, and reusable scalar fills can apply that
composition directly while preserving the same stream as repeated
`Kumaraswamy.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Kumaraswamy.fillFrom` to keep the existing
  point-mass, beta-one square-root, beta-one, and alpha-one paths, then draw one
  open-uniform value per output and apply the generic inverse-CDF transform
  directly instead of calling `Kumaraswamy.sampleFrom` for every output.
- Focused tests compare f64 and f32 reusable Kumaraswamy fills with
  `Kumaraswamy.sampleFrom` loops under identical seeds; existing focused coverage
  still checks edge fill paths and degenerate no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M876 is closed for the current bar: reusable `Kumaraswamy.fillFrom` now avoids
per-sample `Kumaraswamy.sampleFrom` wrapper calls for generic fills while
preserving stream shape and existing edge-case fast paths. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
