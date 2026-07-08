# S4-M877 Zipf Reusable Fill Direct Rejection Loop

## Gap

Reusable `Zipf.fillFrom` still routed every non-degenerate output through
`Zipf.sampleFrom`, adding a wrapper call before running the cached inverse-CDF
proposal and rejection check.

## Local `rand_distr` Baseline

Local `rand_distr` 0.6.0 samples `Zipf` from a cached sampler via inverse-CDF
proposal plus a uniform rejection check. Alea's scalar Zipf sampler uses the same
cached rejection structure, so reusable fills can run the proposal/rejection loop
directly while preserving the same stream as repeated `Zipf.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `Zipf.fillFrom` to keep the degenerate
  no-consume path, then run the cached inverse-CDF proposal and rejection check
  directly for each destination element instead of calling `Zipf.sampleFrom` for
  every output.
- Focused tests compare reusable Zipf fills with `Zipf.sampleFrom` loops under
  identical seeds for both exponent 1.5 and the harmonic exponent 1 path;
  existing focused coverage still checks degenerate no-consume behavior.

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
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M877 is closed for the current bar: reusable `Zipf.fillFrom` now avoids
per-sample `Zipf.sampleFrom` wrapper calls for non-degenerate fills while
preserving stream shape and degenerate no-consume behavior. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
