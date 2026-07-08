# S4-M1012 Triangular Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `Triangular` facade sample/fill helpers still routed
through `sampleFrom` / `fillFrom` wrappers. The direct-source paths already draw
uniform values and apply the triangular transform directly; the facade paths can
now do the same through facade `Rng` while preserving degenerate point-mass
behavior.

## Local `rand` Baseline

Local Rust `rand_distr` `Triangular` reusable samplers sample from the supplied
RNG reference. Alea's scalar/vector reusable Triangular facade helpers should
likewise drive facade `Rng` directly instead of bouncing through direct-source
aliases.

## Implementation

- `src/distributions.zig` updates `Triangular(T).sample` and `Triangular(T).fill`
  to draw uniform values directly through facade `Rng` and apply the triangular
  transform, with a degenerate point-mass fast path.
- `src/distributions.zig` updates `VectorTriangular(VectorType).sample` and
  `VectorTriangular(VectorType).fill` to draw vector uniform values directly
  through facade `Rng` and apply the vector triangular transform, with a
  degenerate point-mass fast path.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and top-level helpers.

## Validation

Focused Triangular tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate triangular helpers do not consume random stream"
1/2 distributions.test.degenerate triangular helpers do not consume random stream...OK
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
examplecheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M1012 is closed for the current bar: reusable scalar/vector Triangular facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate point-mass no-consume behavior, and zero-length checked
fill semantics. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
