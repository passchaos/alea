# S4-M1009 FisherF Top-Level Facade Direct Paths

## Gap

Top-level scalar/vector FisherF facade helpers still routed through direct-source
`From` wrappers. S4-M1008 made reusable scalar/vector FisherF facade sample/fill
paths direct; the top-level checked/nonchecked helpers can now construct reusable
samplers once and call facade `sample` / `fill` directly while preserving
infinite-degree point-mass and zero-length checked-fill semantics.

## Local `rand` Baseline

Local Rust `rand_distr` `FisherF` workflows sample via reusable samplers and RNG
references. Alea's top-level scalar/vector FisherF helpers should likewise drive
facade `Rng` directly rather than bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates scalar `fisherF` / `fisherFChecked` to
  construct `FisherF(T)` once and call facade `sample` directly.
- `src/distributions.zig` updates scalar `fillFisherF` / `fillFisherFChecked` to
  construct `FisherF(T)` once and call facade `fill` directly while preserving
  unchecked infinite-degree point-mass and checked zero-length fast paths.
- `src/distributions.zig` updates `vectorFisherF`, `vectorFisherFChecked`,
  `fillVectorFisherF`, and `fillVectorFisherFChecked` to construct
  `VectorFisherF` once and call facade `sample` / `fill` directly.

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
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M1009 is closed for the current bar: top-level scalar/vector FisherF facade
helpers now avoid direct-source wrapper aliases while preserving stream shape,
infinite-degree point-mass no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
