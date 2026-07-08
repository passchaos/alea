# S4-M834 HalfNormal Reusable Fill Delegates to Optimized Helper

## Gap

Top-level `fillHalfNormalFrom` already handles degenerate output and routes the
optimized f64 bulk-normal-plus-abs path where available. Reusable
`HalfNormal.fillFrom` still implemented its own loop through `HalfNormal.sampleFrom`,
missing the shared helper's optimized path and adding a wrapper call per output.

## Local `rand_distr` Baseline

Reusable distribution fills should share the same underlying implementation as
top-level fill helpers so callers get consistent stream shape and optimized bulk
behavior. Alea's reusable `HalfNormal` can delegate directly to
`fillHalfNormalFrom`.

## Implementation

- `src/distributions.zig` updates `HalfNormal.fillFrom` to call
  `fillHalfNormalFrom(source, T, dest, self.scale)`.
- Focused tests compare reusable fills with top-level `fillHalfNormalFrom` under
  identical seeds, proving output values and stream position stay aligned.

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
readmecheck ok
toolingcheck ok
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M834 is closed for the current bar: reusable `HalfNormal.fillFrom` now reuses
`fillHalfNormalFrom` instead of looping through `HalfNormal.sampleFrom`, preserving
stream shape while sharing the optimized helper path. This is reliability/
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
