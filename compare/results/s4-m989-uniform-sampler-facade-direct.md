# S4-M989 Uniform Sampler Facade Direct Paths

## Gap

Reusable `Uniform(T).sample` and `Uniform(T).fill` facade helpers still routed
through `sampleFrom` / `fillFrom` wrappers. The reusable sampler already caches
whether the range is half-open or inclusive, so facade calls can dispatch directly
to the appropriate `Rng` range helpers or inclusive scalar loops while preserving
stream shape and deterministic degenerate range behavior.

## Local `rand` Baseline

Local Rust `rand` uses reusable `Uniform` samplers to sample directly from an RNG
reference. Alea's reusable `Uniform(T)` should likewise drive the facade `Rng`
directly instead of bouncing through direct-source aliases, while preserving its
Zig-native inclusive range support and degenerate inclusive point masses.

## Implementation

- `src/distributions.zig` updates `Uniform(T).sample` to dispatch half-open
  integer/float ranges directly through facade `Rng` range methods and inclusive
  integer/float ranges through direct facade RNG logic.
- `src/distributions.zig` updates `Uniform(T).fill` to dispatch half-open fills
  through facade `Rng.fillRange`, and inclusive fills through direct integer or
  closed-unit floating-point loops with degenerate point-mass fast paths.
- Direct-source `Uniform(T).sampleFrom` / `fillFrom` remain unchanged for callers
  that explicitly use direct-source workflows.

## Validation

Focused Uniform tests:

```text
$ zig test src/distributions.zig --test-filter "basic distributions stay in expected ranges"
1/2 distributions.test.basic distributions stay in expected ranges...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid uniform distribution helpers do not consume random stream"
1/2 distributions.test.invalid uniform distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate uniform distribution helpers do not consume random stream"
1/2 distributions.test.degenerate uniform distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length base distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length base distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M989 is closed for the current bar: reusable scalar `Uniform(T)` facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape, inclusive endpoint behavior, and degenerate inclusive no-consume
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
