# S4-M1004 Erlang Top-Level Facade Direct Paths

## Gap

Top-level scalar/vector Erlang facade helpers still routed through direct-source
`From` wrappers. S4-M1003 made reusable scalar/vector Erlang facade sample/fill
paths direct; the top-level checked/nonchecked helpers can now construct reusable
samplers once and call facade `sample` / `fill` directly while preserving
zero-length checked-fill semantics.

## Local `rand` Baseline

Local Rust `rand_distr` Erlang-style workflows are Gamma workflows with integer
shape and sample from the supplied RNG reference. Alea's top-level scalar/vector
Erlang helpers should likewise drive facade `Rng` directly rather than bouncing
through direct-source aliases.

## Implementation

- `src/distributions.zig` updates scalar `erlang` / `erlangChecked` to construct
  `Erlang(T)` once and call facade `sample` directly.
- `src/distributions.zig` updates scalar `fillErlang` / `fillErlangChecked` to
  construct `Erlang(T)` once and call facade `fill` directly while preserving the
  unchecked degenerate scale-zero fast path and checked zero-length fast path.
- `src/distributions.zig` updates `vectorErlang`, `vectorErlangChecked`,
  `fillVectorErlang`, and `fillVectorErlangChecked` to construct `VectorErlang`
  once and call facade `sample` / `fill` directly.

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
roadmapcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M1004 is closed for the current bar: top-level scalar/vector Erlang facade
helpers now avoid direct-source wrapper aliases while preserving stream shape,
degenerate no-consume behavior, and zero-length checked fill semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
