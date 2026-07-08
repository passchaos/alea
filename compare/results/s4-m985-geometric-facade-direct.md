# S4-M985 Geometric Facade Direct Paths

## Gap

Scalar `Geometric` and `GeometricFailures` facade helpers still routed through
`From` wrappers or through reusable `sampleFrom` / `fillFrom` methods before
reaching the underlying inverse-CDF sampler. Earlier S4-M825/S4-M826 work made
scalar direct-source fill loops direct; this closes the matching facade paths for
top-level checked/nonchecked helpers and reusable facade sample/fill methods.

## Local `rand` Baseline

Local Rust `rand_distr 0.6.0` exposes `Geometric` as a failure-count sampler via
`Distribution::sample(&mut rng)`. Alea keeps Zig-native one-based `Geometric`
trial-count semantics and maps the Rust failure-count workflow to
`GeometricFailures`; both facade samplers should draw directly from the facade
`Rng` instead of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates scalar top-level `geometric`,
  `geometricChecked`, `fillGeometric`, and `fillGeometricChecked` to construct a
  `Geometric` sampler once and call `sample` / `fill` directly.
- `src/distributions.zig` updates scalar top-level `geometricFailures`,
  `geometricFailuresChecked`, `fillGeometricFailures`, and
  `fillGeometricFailuresChecked` to construct a `GeometricFailures` sampler once
  and call `sample` / `fill` directly.
- Reusable `Geometric.sample`, `Geometric.fill`, `GeometricFailures.sample`, and
  `GeometricFailures.fill` now execute degenerate `p == 1` fast paths and the
  inverse-CDF draw loop directly through facade `Rng` instead of delegating to
  direct-source wrappers.
- Checked fill facades keep the existing zero-length fast path so empty
  destinations neither validate `p` nor consume random input.

## Validation

Focused scalar Geometric tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution facade discrete scalars do not consume random stream"
1/2 distributions.test.invalid distribution facade discrete scalars do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid probability distribution fills do not consume random stream"
1/2 distributions.test.invalid probability distribution fills do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length discrete distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length discrete distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate discrete distribution helpers do not consume random stream"
1/2 distributions.test.degenerate discrete distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid checked distribution helpers do not consume random stream"
1/2 distributions.test.invalid checked distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M985 is closed for the current bar: scalar Geometric and GeometricFailures
facade helpers now avoid direct-source wrapper aliases while preserving stream
shape, degenerate no-consume behavior, checked invalid-parameter behavior, and
zero-length checked fill semantics. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
