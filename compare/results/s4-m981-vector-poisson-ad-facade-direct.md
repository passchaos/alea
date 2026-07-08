# S4-M981 VectorPoissonAhrensDieter Facade Direct Paths

## Gap

Reusable `VectorPoissonAhrensDieter.sample` and `fill` facade helpers still routed
through their direct-source wrappers. S4-M870 made `fillFrom` direct, but facade
sample/fill still had wrapper hops before lane-wise Ahrens-Dieter sampling.

## Local `rand` Baseline

Local Rust `rand_distr` Poisson workflows sample directly from an RNG reference.
Alea's vector Ahrens-Dieter helper is a Zig-native vector-lane convenience over a
cached Poisson method; facade sample/fill should draw lanes directly through the
facade `Rng`.

## Implementation

- `src/distributions.zig` updates `VectorPoissonAhrensDieter.sample` to fill vector
  lanes directly from the cached `PoissonAhrensDieter` method through facade
  `Rng`.
- `src/distributions.zig` updates `VectorPoissonAhrensDieter.fill` to fill each
  output vector directly from the cached method instead of routing through
  `fillFrom`.
- Focused tests compare facade/direct vector stream shape and support bounds.

## Validation

Focused vector Poisson test:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
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
toolingcheck ok
roadmapcheck ok
apicheck ok
```

## Result

S4-M981 is closed for the current bar: reusable VectorPoissonAhrensDieter facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving lane
stream shape. This is reliability/ergonomics work only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
