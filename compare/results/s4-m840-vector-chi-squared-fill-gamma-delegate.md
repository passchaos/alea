# S4-M840 VectorChiSquared Reusable Fill Delegates to VectorGamma Fill

## Gap

S4-M839 made scalar reusable `ChiSquared.fillFrom` delegate to the cached Gamma
sampler fill. Reusable `VectorChiSquared.fillFrom` still looped through
`VectorChiSquared.sampleFrom` for every non-degenerate vector output, missing the
shape-specific `VectorGamma.fillFrom` bulk paths added in S4-M838, including the
`dof == 2` shape-one standard-vector-exponential staging path.

## Local `rand_distr` Baseline

Local `rand_distr` implements chi-squared sampling through Gamma composition for
all degrees of freedom except its scalar `dof == 1` normal-square special case.
Alea's reusable `VectorChiSquared` stores a cached scalar `ChiSquared`, which in
turn caches the Gamma sampler, so vector fills can compose through
`VectorGamma.fillFrom` over that cached Gamma state instead of repeating a
`VectorChiSquared.sampleFrom` wrapper per vector.

## Implementation

- `src/distributions.zig` updates `VectorChiSquared.fillFrom` to keep the
  dof-zero degenerate no-consume path, then delegate to `VectorGamma(VectorType)`
  constructed from the cached Gamma sampler.
- Focused tests compare dof-two `VectorChiSquared.fillFrom` with equivalent
  `VectorGamma(1, 2).fillFrom`, compare f32x8 fills with scalar
  `VectorChiSquared.sampleFrom` loops, and cover dof-zero no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
toolingcheck ok
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M840 is closed for the current bar: reusable `VectorChiSquared.fillFrom` now
reuses the cached Gamma sampler through `VectorGamma.fillFrom` instead of routing
every output through `VectorChiSquared.sampleFrom`, preserving stream shape while
sharing vector Gamma's optimized bulk cases. This is reliability/ergonomics work
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
