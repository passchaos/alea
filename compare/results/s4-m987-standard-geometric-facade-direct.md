# S4-M987 StandardGeometric Facade Direct Paths

## Gap

Scalar/vector `StandardGeometric` top-level helpers and reusable facade sample/fill
methods still routed through `From` wrappers. S4-M985 and S4-M986 made the
parameterized scalar/vector geometric facade paths direct; the standard
`p = 0.5` optimized helpers can likewise execute their leading-zero loop directly
through facade `Rng`.

## Local `rand` Baseline

Local Rust `rand_distr 0.6.0` exposes `StandardGeometric` as the optimized
failure-count `Geometric(0.5)` distribution via `Distribution::sample(&mut rng)`,
implemented as a leading-zero loop over RNG words. Alea's scalar and vector
standard geometric facade helpers should draw directly from the facade `Rng`
instead of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `standardGeometric` and `fillStandardGeometric`
  to run the leading-zero loop directly through facade `Rng`.
- `src/distributions.zig` updates `vectorStandardGeometric` and
  `fillVectorStandardGeometric` to call reusable vector facade sample/fill paths
  directly.
- Reusable `VectorStandardGeometric.sample`, `VectorStandardGeometric.fill`,
  `StandardGeometric.sample`, and `StandardGeometric.fill` now execute direct
  facade loops instead of delegating to `sampleFrom` / `fillFrom` wrappers.

## Validation

Focused StandardGeometric tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate discrete distribution helpers do not consume random stream"
1/2 distributions.test.degenerate discrete distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M987 is closed for the current bar: scalar/vector StandardGeometric facade
helpers now avoid direct-source wrapper aliases while preserving stream shape and
the optimized leading-zero semantics. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
