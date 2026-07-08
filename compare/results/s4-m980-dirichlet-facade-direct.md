# S4-M980 Dirichlet Facade Direct Paths

## Gap

Reusable `Dirichlet` allocation-returning and caller-buffer facade helpers still
routed through their direct-source `From` wrappers. The direct-source algorithms
were already implemented, so facade helpers can allocate or validate once and run
the Dirichlet gamma-normalization logic directly through the facade `Rng` while
preserving stream shape, degenerate behavior, and no-consume validation behavior.

## Local `rand` Baseline

Local Rust `rand_distr` Dirichlet workflows sample simplex vectors directly from
an RNG reference. Alea's reusable `Dirichlet` sampler exposes allocation-returning,
single-output, and many-output facades; those facades should not require
direct-source wrapper hops.

## Implementation

- `src/distributions.zig` updates `Dirichlet.sample` to allocate the output and
  call facade `sampleInto` directly.
- `src/distributions.zig` updates `sampleInto` and `sampleIntoChecked` to execute
  degenerate cases and gamma-normalization directly through facade `Rng`.
- `src/distributions.zig` updates `sampleManyInto` and `sampleManyIntoChecked` to
  handle degenerate cases and repeated simplex samples directly through facade
  `Rng`.
- Focused tests cover allocation failure/no-consume behavior, invalid output
  lengths, zero-length batch outputs, degenerate vertices, and normal simplex
  sample stream shape.

## Validation

Focused Dirichlet tests:

```text
$ zig test src/distributions.zig --test-filter "dirichlet sampler returns simplex vectors"
1/2 distributions.test.dirichlet sampler returns simplex vectors...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid multivariate output lengths do not consume random stream"
1/2 distributions.test.invalid multivariate output lengths do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length multivariate batch outputs do not consume random stream"
1/2 distributions.test.zero-length multivariate batch outputs do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M980 is closed for the current bar: reusable Dirichlet facade helpers now
avoid direct-source wrapper aliases while preserving stream shape, allocation
behavior, degenerate vertices, and checked no-consume validation. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
