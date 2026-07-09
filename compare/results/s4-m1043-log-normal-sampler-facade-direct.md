# S4-M1043 LogNormal Sampler Facade Direct Paths

## Gap

Reusable scalar `LogNormal(T)` facade `sample` / `fill` still routed through
`sampleFrom` / `fillFrom`. The facade-level log-normal helpers already drive
facade `Rng` directly and preserve degenerate `stddev == 0` no-consume behavior,
so the reusable scalar sampler facade can call those helpers directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Rust `rand_distr`
reusable samplers draw from the supplied RNG; Alea's reusable `LogNormal(T)`
facade helpers should likewise drive the facade RNG directly instead of bouncing
through explicit direct-source aliases.

## Implementation

- `src/distributions.zig` updates `LogNormal(T).sample` to call the top-level
  facade `logNormal` helper directly.
- `src/distributions.zig` updates `LogNormal(T).fill` to call facade
  `fillLogNormal` directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused LogNormal tests:

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
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
apicheck ok
```

## Result

S4-M1043 is closed for the current bar: reusable scalar LogNormal facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
