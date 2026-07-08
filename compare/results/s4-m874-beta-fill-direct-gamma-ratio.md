# S4-M874 Beta Reusable Fill Direct Gamma Ratio

## Gap

Reusable `Beta.fillFrom` already had point-mass, uniform, and square-root edge
paths, but the generic path still routed every output through `Beta.sampleFrom`,
adding a wrapper call before drawing the two cached Gamma samplers and normalizing
their ratio.

## Local `rand_distr` Baseline

Local `rand_distr` represents `Beta` as a cached reusable sampler and dispatches
to the selected beta algorithm. Alea's generic Beta method is a cached two-Gamma
composition, so reusable scalar fills can draw both cached Gamma samplers and
normalize directly while preserving the same stream as repeated `Beta.sampleFrom`
calls.

## Implementation

- `src/distributions.zig` updates `Beta.fillFrom` to keep the existing point-mass,
  uniform, and square-root edge paths, then draw `gamma_a` and `gamma_b` directly
  and write `x / (x + y)` for generic fills instead of calling `Beta.sampleFrom`
  for every output.
- Focused tests compare f64 and f32 reusable Beta fills with `Beta.sampleFrom`
  loops under identical seeds; existing focused coverage still checks edge fill
  paths and degenerate no-consume behavior.

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
toolingcheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M874 is closed for the current bar: reusable `Beta.fillFrom` now avoids
per-sample `Beta.sampleFrom` wrapper calls for generic fills while preserving
stream shape and existing edge-case fast paths. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
