# S4-M1038 Exponential Sampler Facade Direct Paths

## Gap

Reusable scalar `Exponential(T)` facade `sample` / `fill` still routed through
`sampleFrom` / `fillFrom`. The facade-level exponential and standard-exponential
helpers already drive facade `Rng` directly and preserve degenerate `rate == inf`
no-consume behavior, so the reusable scalar sampler facade can call those helpers
directly.

## Local `rand` / `rand_distr` Baseline

The local `rand` checkout remains the primary baseline. Rust `rand_distr`
reusable samplers draw from the supplied RNG; Alea's reusable `Exponential(T)`
facade helpers should likewise drive the facade RNG directly instead of bouncing
through explicit direct-source aliases.

## Implementation

- `src/distributions.zig` updates `Exponential(T).sample` to draw through facade
  `rng.exponential(T, 1)` and scale by the cached inverse rate.
- `src/distributions.zig` updates `Exponential(T).fill` to draw through facade
  `fillStandardExponential` and scale in place when needed.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused Exponential tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate exponential distribution helpers do not consume random stream"
1/2 distributions.test.degenerate exponential distribution helpers do not consume random stream...OK
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
examplecheck ok
toolingcheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1038 is closed for the current bar: reusable scalar Exponential facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, degenerate no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
