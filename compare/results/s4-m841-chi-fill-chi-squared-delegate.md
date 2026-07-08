# S4-M841 Chi Reusable Fill Delegates to ChiSquared Fill

## Gap

Reusable `Chi.fillFrom` still looped through `Chi.sampleFrom` for every
non-degenerate output. Since `Chi` stores a cached `ChiSquared` sampler and each
sample is `sqrt(chi_squared)`, bulk fills could reuse the cached
`ChiSquared.fillFrom` path and apply square root in place. This also shares the
recent chi-square/Gamma shape-specific bulk paths, including dof-two
standard-exponential staging.

## Local `rand_distr` Baseline

Local `rand_distr` exposes chi-squared as a Gamma-backed distribution. Alea's
`Chi` is Zig-native and built on `ChiSquared`; for bulk fills it can compose with
that cached sampler directly instead of repeating a `Chi.sampleFrom` wrapper per
output.

## Implementation

- `src/distributions.zig` updates `Chi.fillFrom` to keep the dof-zero degenerate
  no-consume path, then call `self.chi_squared_sampler.fillFrom(source, dest)`
  and transform the destination in place with `@sqrt`.
- Focused tests compare dof-two `Chi.fillFrom` with equivalent
  `ChiSquared(2).fillFrom` plus square root, compare f32 fills with scalar
  `Chi.sampleFrom` loops, and cover dof-zero no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
roadmapcheck ok
readmecheck ok
```

## Result

S4-M841 is closed for the current bar: reusable `Chi.fillFrom` now reuses the
cached `ChiSquared` sampler fill path and applies square root in place instead
of routing every output through `Chi.sampleFrom`, preserving stream shape while
sharing chi-square/Gamma optimized bulk cases. This is reliability/ergonomics
work only; it does not resolve S4-M11 and is not whole-goal completion evidence.
