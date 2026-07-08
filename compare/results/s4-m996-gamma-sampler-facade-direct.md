# S4-M996 Gamma Sampler Facade Direct Paths

## Gap

Reusable scalar `Gamma(T).sample` and `Gamma(T).fill` facade helpers still routed
through `sampleFrom` / `fillFrom` wrappers. S4-M873 made the direct-source fill
method dispatch direct; the facade sample/fill methods can now execute the same
degenerate, shape-one, boosted-small-shape, and Marsaglia paths directly through
facade `Rng`.

## Local `rand` Baseline

Local Rust `rand_distr` `Gamma` reusable samplers sample directly from an RNG
reference. Alea's reusable scalar Gamma facade should likewise drive the facade
`Rng` directly rather than bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `Gamma(T).sample` to execute degenerate,
  shape-one standard-exponential, boosted small-shape, and regular Marsaglia
  paths directly through facade `Rng`.
- `src/distributions.zig` updates `Gamma(T).fill` to fill degenerate buffers,
  shape-one standard-exponential buffers, boosted small-shape values, and regular
  Marsaglia values directly through facade `Rng` instead of delegating to
  `fillFrom`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and existing composition helpers.

## Validation

Focused Gamma tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
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

S4-M996 is closed for the current bar: reusable scalar Gamma facade sample/fill
helpers now avoid direct-source wrapper aliases while preserving stream shape,
degenerate no-consume behavior, and checked zero-length fill semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
