# S4-M842 VectorChi Reusable Fill Delegates to VectorChiSquared Fill

## Gap

S4-M841 made scalar reusable `Chi.fillFrom` delegate to the cached
`ChiSquared.fillFrom` and apply square root in place. Reusable
`VectorChi.fillFrom` still looped through `VectorChi.sampleFrom` for every
non-degenerate vector output, missing the vector chi-square/Gamma bulk paths
added in recent milestones, including dof-two standard-vector-exponential
staging.

## Local `rand_distr` Baseline

Local `rand_distr` exposes chi-squared as the core Gamma-backed primitive used by
related continuous distributions. Alea's vector Chi sampler is Zig-native and
built on `VectorChiSquared`; vector bulk fills can compose through that cached
sampler directly and then apply vector square root, avoiding per-vector wrapper
calls while preserving the same stream.

## Implementation

- `src/distributions.zig` updates `VectorChi.fillFrom` to keep the dof-zero
  degenerate no-consume path, then call `VectorChiSquared(VectorType)` over the
  cached `ChiSquared` sampler and transform each vector in place with `@sqrt`.
- Focused tests compare dof-two `VectorChi.fillFrom` with equivalent
  `VectorChiSquared(2).fillFrom` plus vector square root, compare f32x8 fills
  with scalar `VectorChi.sampleFrom` loops, and cover dof-zero no-consume
  behavior.

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
apicheck ok
examplecheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M842 is closed for the current bar: reusable `VectorChi.fillFrom` now reuses
the cached `VectorChiSquared` fill path and applies vector square root in place
instead of routing every output through `VectorChi.sampleFrom`, preserving stream
shape while sharing vector chi-square/Gamma optimized bulk cases. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
