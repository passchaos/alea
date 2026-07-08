# S4-M988 Bernoulli Top-Level Facade Direct Paths

## Gap

Top-level scalar/vector Bernoulli facade helpers still routed through their
`From` wrappers. S4-M965 and S4-M966 already made reusable Bernoulli sample/fill
facade methods direct, so the top-level helpers can construct the reusable
sampler once and call facade `sample` / `fill` directly while preserving checked
validation and zero-length checked-fill behavior.

## Local `rand` Baseline

Local Rust `rand` / `rand_distr` Bernoulli workflows sample and fill through RNG
reference entry points. Alea's top-level scalar/vector Bernoulli facade helpers
should likewise use facade `Rng` directly instead of bouncing through
direct-source aliases.

## Implementation

- `src/distributions.zig` updates scalar `bernoulli` and `bernoulliChecked` to
  construct `Bernoulli` once and call `dist.sample(rng)` directly.
- `src/distributions.zig` updates scalar `fillBernoulli` and
  `fillBernoulliChecked` to construct `Bernoulli` once and call
  `dist.fill(rng, dest)` directly.
- `src/distributions.zig` updates vector `vectorBernoulli`,
  `vectorBernoulliChecked`, `fillVectorBernoulli`, and
  `fillVectorBernoulliChecked` to construct `VectorBernoulli` once and call
  facade `sample` / `fill` directly.
- Checked fill facades keep the existing zero-length fast path so empty
  destinations neither validate `p` nor consume random input.

## Validation

Focused Bernoulli tests:

```text
$ zig test src/distributions.zig --test-filter "basic distributions stay in expected ranges"
1/2 distributions.test.basic distributions stay in expected ranges...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution facade discrete scalars do not consume random stream"
1/2 distributions.test.invalid distribution facade discrete scalars do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid distribution vector helpers do not consume random stream"
1/2 distributions.test.invalid distribution vector helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length discrete distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length discrete distribution fills do not validate or consume random stream...OK
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
readmecheck ok
examplecheck ok
apicheck ok
toolingcheck ok
roadmapcheck ok
```

## Result

S4-M988 is closed for the current bar: scalar/vector top-level Bernoulli facade
helpers now avoid direct-source wrapper aliases while preserving stream shape,
degenerate no-consume behavior, checked invalid-probability behavior, and
zero-length checked fill semantics. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
