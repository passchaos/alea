# S4-M1034 Normal Fill Facade Direct Path

## Gap

Reusable scalar `Normal(T).fill` still delegated through `fillFrom`. The
facade-level normal bulk helper already drives facade `Rng` directly and
preserves the same parameter validation and degenerate `stddev == 0` no-consume
behavior, so the reusable sampler facade can call it directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Rust `rand_distr::Normal`
reusable samplers draw from the supplied RNG; Alea's reusable `Normal(T).fill`
should likewise drive the facade RNG directly instead of routing through the
explicit direct-source alias.

## Implementation

- `src/distributions.zig` updates `Normal(T).fill` to call
  `rng.fillNormal(T, dest, mean, stddev)` directly.
- `Normal(T).sample`, `sampleFrom`, and `fillFrom` remain unchanged for scalar
  and direct-source workflows.

## Validation

Focused Normal tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate normal and log-normal helpers do not consume random stream"
1/2 distributions.test.degenerate normal and log-normal helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length derived distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length derived distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "rand_distr Normal parameter aliases mirror value accessors"
1/1 distributions.test.rand_distr Normal parameter aliases mirror value accessors...OK
All 1 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M1034 is closed for the current bar: reusable scalar Normal facade fill now
avoids the direct-source wrapper alias while preserving stream shape, degenerate
no-consume behavior, and zero-length checked fill semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
