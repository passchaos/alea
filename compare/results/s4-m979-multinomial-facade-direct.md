# S4-M979 Multinomial Facade Direct Paths

## Gap

Reusable `Multinomial` allocation-returning and caller-buffer facade helpers still
routed through their direct-source `From` wrappers. The direct-source algorithms
were already implemented, so facade helpers can allocate or validate once and run
the multinomial sampling logic directly through the facade `Rng` while preserving
stream shape and no-consume validation behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` multinomial-style workflows sample category
counts directly from an RNG reference. Alea's reusable `Multinomial` sampler
exposes allocation-returning, single-output, and many-output facades; those
facades should not require direct-source wrapper hops.

## Implementation

- `src/distributions.zig` updates `Multinomial.sample` to allocate the output and
  call facade `sampleInto` directly.
- `src/distributions.zig` updates `sampleInto` and `sampleIntoChecked` to execute
  the multinomial sequential-binomial sampling loop directly through facade `Rng`.
- `src/distributions.zig` updates `sampleManyInto` and `sampleManyIntoChecked` to
  handle degenerate cases and repeated samples directly through facade `Rng`.
- Focused tests cover allocation failure/no-consume behavior, invalid output
  lengths, zero-length batch outputs, and normal sample stream shape.

## Validation

Focused Multinomial tests:

```text
$ zig test src/distributions.zig --test-filter "multinomial sampler returns category counts"
1/2 distributions.test.multinomial sampler returns category counts...OK
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
roadmapcheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M979 is closed for the current bar: reusable Multinomial facade helpers now
avoid direct-source wrapper aliases while preserving stream shape, allocation
behavior, and checked no-consume validation. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
