# S4-M1003 Erlang Sampler Facade Direct Paths

## Gap

Reusable scalar/vector `Erlang` facade sample/fill helpers still routed through
`sampleFrom` / `fillFrom` wrappers. The Erlang samplers are backed by cached Gamma
samplers, and S4-M996 through S4-M998 made Gamma facade paths direct; Erlang can
therefore dispatch through cached Gamma facade samplers directly.

## Local `rand` Baseline

Local Rust `rand_distr` Erlang-style workflows are Gamma workflows with integer
shape and sample from the supplied RNG reference. Alea's scalar/vector reusable
Erlang facade helpers should likewise drive facade `Rng` directly instead of
bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `Erlang(T).sample` and `Erlang(T).fill` to call
  the cached Gamma sampler's facade `sample` / `fill` directly.
- `src/distributions.zig` updates `VectorErlang(VectorType).sample` and
  `VectorErlang(VectorType).fill` to construct a `VectorGamma` view over the
  cached Gamma sampler and call facade `sample` / `fill` directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and existing composition helpers.

## Validation

Focused Erlang/Gamma tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate erlang helpers do not consume random stream"
1/2 distributions.test.degenerate erlang helpers do not consume random stream...OK
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
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M1003 is closed for the current bar: reusable scalar/vector Erlang facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
