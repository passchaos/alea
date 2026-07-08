# S4-M1010 StudentT Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `StudentT` facade sample/fill helpers still routed through
`sampleFrom` / `fillFrom` wrappers. S4-M999 through S4-M1002 made ChiSquared/Chi
facade paths direct; StudentT can now draw standard-normal and ChiSquared values
directly through facade `Rng` while preserving infinite-degree behavior.

## Local `rand` Baseline

Local Rust `rand_distr` `StudentT` samples from the supplied RNG reference and
uses standard-normal/chi-square style composition. Alea's scalar/vector reusable
StudentT facade helpers should likewise drive facade `Rng` directly instead of
bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `StudentT(T).sample` and `StudentT(T).fill` to
  draw standard-normal and cached ChiSquared samples directly through facade
  `Rng`, with direct standard-normal behavior for infinite degrees of freedom.
- `src/distributions.zig` updates `VectorStudentT(VectorType).sample` and
  `VectorStudentT(VectorType).fill` to draw each vector lane directly through
  facade `Rng`, with direct vector standard-normal behavior for infinite degrees
  of freedom.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level helpers.

## Validation

Focused StudentT tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "infinite-dof student-t preserves standard-normal stream shape"
1/2 distributions.test.infinite-dof student-t preserves standard-normal stream shape...OK
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
roadmapcheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M1010 is closed for the current bar: reusable scalar/vector StudentT facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, infinite-degree standard-normal behavior, and zero-length checked
fill semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
