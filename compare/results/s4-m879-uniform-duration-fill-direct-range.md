# S4-M879 UniformDuration Reusable Fill Direct Range Dispatch

## Gap

Reusable `UniformDuration.fillFrom` still routed every output through
`UniformDuration.sampleFrom`, adding a wrapper call before dispatching to the
half-open or inclusive duration range helper.

## Local `rand` Baseline

Local Rust `rand` exposes `UniformDuration` as a reusable duration-range sampler
for `core::time::Duration`. Alea's `UniformDuration` is Zig-native over
`std.Io.Duration`, and its sampling semantics are implemented by the existing
`Rng.durationRangeLessThanFrom` and `Rng.durationRangeAtMostFrom` helpers. Since
those helpers already encode the half-open, inclusive, and inclusive point-mass
stream behavior, reusable fills can dispatch directly to the matching helper
while preserving the same stream as repeated `UniformDuration.sampleFrom` calls.

## Implementation

- `src/distributions.zig` updates `UniformDuration.fillFrom` to branch once on
  `isInclusive()` and call `Rng.durationRangeAtMostFrom` or
  `Rng.durationRangeLessThanFrom` directly for each destination element instead
  of calling `UniformDuration.sampleFrom` for every output.
- Focused tests compare half-open and inclusive reusable fills with
  `UniformDuration.sampleFrom` loops under identical seeds; existing focused
  coverage still checks inclusive point-mass no-consume behavior.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "UniformDuration sampler mirrors duration helpers"
1/2 distributions.test.UniformDuration sampler mirrors duration helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M879 is closed for the current bar: reusable `UniformDuration.fillFrom` now
avoids per-output `UniformDuration.sampleFrom` wrapper calls while preserving
half-open, inclusive, and point-mass duration stream behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
