# S4-M1008 FisherF Sampler Facade Direct Paths

## S4-M1148 Supersession Note

S4-M1148 later replaces the former both-infinite FisherF deterministic edge with local `rand_distr`-compatible NaN output while preserving the corresponding ChiSquared/Gamma draw shape. The facade/direct routing conclusions below remain relevant for finite FisherF paths; infinite-degree edge semantics now come from S4-M1148.

## Gap

Reusable scalar/vector `FisherF` facade sample/fill helpers still routed through
`sampleFrom` / `fillFrom` wrappers. S4-M999 through S4-M1002 made ChiSquared/Chi
facade paths direct, and S4-M996/S4-M997 made Gamma facade paths direct; FisherF
can now draw numerator and denominator Gamma values directly through facade
`Rng` while preserving the then-current infinite-degree edge behavior; S4-M1148 later supersedes that edge with rand_distr-compatible NaN/draw-shape semantics.

## Local `rand` Baseline

Local Rust `rand_distr` `FisherF` composes chi-square/Gamma-family sampling and
samples from the supplied RNG reference. Alea's scalar/vector reusable FisherF
facade helpers should likewise drive facade `Rng` directly instead of bouncing
through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `FisherF(T).sample` and `FisherF(T).fill` to
  route infinite-degree cases through the FisherF edge branch and otherwise sample cached
  numerator/denominator Gamma samplers through facade `Rng`.
- `src/distributions.zig` updates `VectorFisherF(VectorType).sample` and
  `VectorFisherF(VectorType).fill` to route vector infinite-degree cases through the FisherF edge branch and
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

$ zig test src/distributions.zig --test-filter "infinite fisher-f helpers preserve rand_distr-compatible stream shape"
1/2 distributions.test.infinite fisher-f helpers preserve rand_distr-compatible stream shape...OK
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
stream shape, current S4-M1148 infinite-degree NaN/draw-shape behavior, and zero-length
checked fill semantics. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
