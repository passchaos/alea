# S4-M982 VectorPoissonAhrensDieter Top-Level Facade Direct Paths

## Gap

Top-level `vectorPoissonAhrensDieter` helpers still routed through their `From`
wrappers. S4-M981 made reusable `VectorPoissonAhrensDieter.sample` and `fill`
facade paths direct, so the top-level facade helpers can construct the reusable
sampler once and call `sample` / `fill` directly while preserving checked
validation and zero-length fill behavior.

## Local `rand` Baseline

Local Rust `rand_distr 0.6.0` Poisson sampling dispatches through the
`Distribution::sample(&mut rng)` facade: small lambdas use Knuth and large
lambdas use Ahrens-Dieter rejection from the supplied RNG reference. Alea's
Ahrens-Dieter vector helper is a Zig-native lane convenience over the same
large-lambda Poisson method; top-level facade helpers should likewise use the
facade `Rng` directly instead of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `vectorPoissonAhrensDieter` and
  `vectorPoissonAhrensDieterChecked` to construct `VectorPoissonAhrensDieter`
  once and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates `fillVectorPoissonAhrensDieter` and
  `fillVectorPoissonAhrensDieterChecked` to construct the reusable vector
  sampler and call `dist.fill(rng, dest)` directly.
- The checked fill facade keeps the existing zero-length fast path so empty
  destinations neither validate `lambda` nor consume random input.
- Focused tests cover vector stream shape, invalid checked paths, and
  zero-length fill no-validation/no-consumption behavior.

## Validation

Focused vector Poisson tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution vector helpers do not consume random stream"
1/2 distributions.test.invalid distribution vector helpers do not consume random stream...OK
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
readmecheck ok
apicheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M982 is closed for the current bar: top-level vector Poisson
Ahrens-Dieter facade helpers now avoid direct-source wrapper aliases while
preserving lane stream shape and checked validation behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
