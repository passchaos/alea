# S4-M991 VectorUniform Sampler Facade Direct Paths

## Gap

Reusable `VectorUniform(VectorType).sample` and `VectorUniform(VectorType).fill`
facade helpers still routed through `sampleFrom` / `fillFrom` wrappers. S4-M989
and S4-M990 made scalar Uniform reusable and top-level facades direct; the
reusable vector sampler can likewise dispatch directly through facade `Rng` range
logic while preserving lane stream shape and degenerate inclusive range behavior.

## Local `rand` Baseline

Local Rust `rand` uses reusable uniform samplers to sample directly from an RNG
reference. Alea's Zig-native reusable vector Uniform sampler extends this to
vector lanes, and facade calls should drive the facade `Rng` directly instead of
bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `VectorUniform(VectorType).sample` to dispatch
  half-open vector ranges directly through facade `Rng.vectorRange`, and
  inclusive integer/float vector ranges through direct facade RNG logic.
- `src/distributions.zig` updates `VectorUniform(VectorType).fill` to dispatch
  half-open vector fills through facade `Rng.fillVectorRange`, and inclusive
  fills through direct integer or closed-unit floating-point vector loops with
  degenerate point-mass fast paths.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for callers that
  explicitly use direct-source workflows.

## Validation

Focused VectorUniform tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
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
toolingcheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M991 is closed for the current bar: reusable `VectorUniform` facade sample/fill
helpers now avoid direct-source wrapper aliases while preserving vector lane
stream shape, inclusive endpoint behavior, and degenerate inclusive no-consume
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
