# S4-M1007 Beta Top-Level Facade Direct Paths

## Gap

Top-level scalar/vector Beta facade helpers still routed through direct-source
`From` wrappers. S4-M1005 and S4-M1006 made reusable scalar and vector Beta
facade sample/fill paths direct; the top-level checked/nonchecked helpers can now
construct reusable samplers once and call facade `sample` / `fill` directly while
preserving scalar unchecked beta-one and edge-case behavior plus zero-length
checked-fill semantics.

## Local `rand` Baseline

Local Rust `rand_distr` `Beta` workflows sample via reusable samplers and RNG
references. Alea's top-level scalar/vector Beta helpers should likewise drive
facade `Rng` directly rather than bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates scalar `beta` / `fillBeta` to dispatch through
  facade `Rng` directly, preserving point-mass, uniform, square-root edge, and
  beta-one power-transform behavior.
- `src/distributions.zig` updates scalar `betaChecked` / `fillBetaChecked` to
  construct `Beta(T)` once and call facade `sample` / `fill` directly.
- `src/distributions.zig` updates `vectorBeta`, `vectorBetaChecked`,
  `fillVectorBeta`, and `fillVectorBetaChecked` to construct `VectorBeta` once
  and call facade `sample` / `fill` directly.
- Checked fill facades keep the existing zero-length fast path so empty
  destinations neither validate parameters nor consume random input.

## Validation

Focused Beta/Gamma tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate gamma helpers do not consume random stream"
1/2 distributions.test.degenerate gamma helpers do not consume random stream...OK
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
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1007 is closed for the current bar: top-level scalar/vector Beta facade
helpers now avoid direct-source wrapper aliases while preserving stream shape,
edge-case behavior, point-mass no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
