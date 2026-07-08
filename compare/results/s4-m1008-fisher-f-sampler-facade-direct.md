# S4-M1008 FisherF Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `FisherF` facade sample/fill helpers still routed through
`sampleFrom` / `fillFrom` wrappers. S4-M999 through S4-M1002 made ChiSquared/Chi
facade paths direct, and S4-M996/S4-M997 made Gamma facade paths direct; FisherF
can now draw numerator and denominator Gamma values directly through facade
`Rng` while preserving degenerate infinite-degree behavior.

## Local `rand` Baseline

Local Rust `rand_distr` `FisherF` composes chi-square/Gamma-family sampling and
samples from the supplied RNG reference. Alea's scalar/vector reusable FisherF
facade helpers should likewise drive facade `Rng` directly instead of bouncing
through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `FisherF(T).sample` and `FisherF(T).fill` to
  execute the infinite-degree point mass directly and otherwise sample cached
  numerator/denominator Gamma samplers through facade `Rng`.
- `src/distributions.zig` updates `VectorFisherF(VectorType).sample` and
  `VectorFisherF(VectorType).fill` to execute the vector point mass directly and
  otherwise sample numerator/denominator Gamma lanes through facade `Rng`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level helpers.

## Validation

Focused FisherF tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate fisher-f helpers do not consume random stream"
1/2 distributions.test.degenerate fisher-f helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length core continuous distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length core continuous distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length distribution vector fills do not validate or consume random stream"
1/2 distributions.test.zero-length distribution vector fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
```

## Result

S4-M1008 is closed for the current bar: reusable scalar/vector FisherF facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, infinite-degree point-mass no-consume behavior, and zero-length
checked fill semantics. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
