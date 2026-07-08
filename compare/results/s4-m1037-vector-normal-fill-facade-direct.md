# S4-M1037 VectorNormal Fill Facade Direct Path

## Gap

Reusable `VectorNormal(VectorType).fill` still delegated through `fillFrom`. The
facade-level vector normal fill helper already drives facade `Rng` directly and
preserves degenerate `stddev == 0` no-consume behavior, so the reusable vector
sampler facade can call it directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Alea's vector normal
surface is Zig-native, but the reusable-sampler contract is the same: facade
helpers should drive the supplied facade RNG directly and avoid avoidable
wrapper hops.

## Implementation

- `src/distributions.zig` updates `VectorNormal(VectorType).fill` to call
  `fillVectorNormal(rng, VectorType, dest, mean, stddev)` directly.
- `VectorNormal.sample`, `sampleFrom`, and `fillFrom` remain unchanged.

## Validation

Focused vector Normal tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate normal and log-normal helpers do not consume random stream"
1/2 distributions.test.degenerate normal and log-normal helpers do not consume random stream...OK
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

S4-M1037 is closed for the current bar: reusable VectorNormal facade fill now
avoids the direct-source wrapper alias while preserving stream shape, degenerate
no-consume behavior, and zero-length checked fill semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
