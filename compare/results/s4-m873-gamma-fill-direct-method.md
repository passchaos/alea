# S4-M873 Gamma Reusable Fill Direct Method Dispatch

## Gap

Reusable `Gamma.fillFrom` already had degenerate and shape-one standard-
exponential fast paths, but the remaining generic path still routed every output
through `Gamma.sampleFrom`, adding a wrapper call and rechecking method state for
each sample.

## Local `rand_distr` Baseline

Local `rand_distr` represents `Gamma` as a cached method enum (`Small`, `One`, or
`Large`) and dispatches to the selected sampler. Alea has equivalent cached state
for scale-zero, shape-one, boosted-small-shape, and regular Marsaglia paths, so
reusable scalar fills can dispatch once and call the cached method directly while
preserving the same stream as repeated `Gamma.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Gamma.fillFrom` to keep the degenerate
  no-consume path and the shape-one standard-exponential fill path, then dispatch
  once between boosted-small-shape and regular Marsaglia paths instead of calling
  `Gamma.sampleFrom` for every output.
- Focused tests compare f64 and f32 reusable Gamma fills with `Gamma.sampleFrom`
  loops under identical seeds for regular shape>1 and boosted shape<1 paths,
  while existing focused coverage still checks the shape-one fast path.

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
examplecheck ok
readmecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M873 is closed for the current bar: reusable `Gamma.fillFrom` now avoids
per-sample `Gamma.sampleFrom` wrapper calls for generic-shape fills while
preserving stream shape and existing degenerate / shape-one fast paths. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
