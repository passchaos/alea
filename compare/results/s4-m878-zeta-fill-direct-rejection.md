# S4-M878 Zeta Reusable Fill Direct Rejection Loop

## Gap

Reusable `Zeta.fillFrom` still routed every non-degenerate output through
`Zeta.sampleFrom`, adding a wrapper call before running the cached open-closed
proposal and rejection check.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 samples `Zeta` from a cached sampler using an
open-closed-uniform proposal and a uniform rejection check. Alea's scalar Zeta
sampler uses the same cached rejection structure, so reusable fills can run the
proposal/rejection loop directly while preserving the same stream as repeated
`Zeta.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Zeta.fillFrom` to keep the degenerate
  no-consume path, then run the cached proposal and rejection check directly for
  each destination element instead of calling `Zeta.sampleFrom` for every output.
- Focused tests compare f64 and f32 reusable Zeta fills with `Zeta.sampleFrom`
  loops under identical seeds; existing focused coverage still checks degenerate
  no-consume behavior.

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
apicheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M878 is closed for the current bar: reusable `Zeta.fillFrom` now avoids
per-sample `Zeta.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
