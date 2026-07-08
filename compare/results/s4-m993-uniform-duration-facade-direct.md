# S4-M993 UniformDuration Facade Direct Paths

## Gap

Reusable `UniformDuration.sample` and `UniformDuration.fill` facade helpers still
routed through `sampleFrom` / `fillFrom` wrappers. S4-M879 already made the
direct-source fill path dispatch directly to duration range helpers; the facade
sample/fill paths can likewise dispatch through facade `Rng` duration range
helpers while preserving inclusive point-mass no-consume behavior.

## Local `rand` Baseline

Local Rust `rand` exposes `UniformDuration` as a reusable duration-range sampler
which samples directly from an RNG reference. Alea's Zig-native `std.Io.Duration`
sampler should drive facade `Rng` directly instead of bouncing through
direct-source aliases.

## Implementation

- `src/distributions.zig` updates `UniformDuration.sample` to call facade
  `rng.durationRangeLessThan` or `rng.durationRangeAtMost` directly depending on
  the sampler's inclusive mode.
- `src/distributions.zig` updates `UniformDuration.fill` to call facade duration
  range helpers directly, with an inclusive point-mass fast path for `low == high`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused UniformDuration test:

```text
$ zig test src/distributions.zig --test-filter "UniformDuration sampler mirrors duration helpers"
1/2 distributions.test.UniformDuration sampler mirrors duration helpers...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
toolingcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M993 is closed for the current bar: reusable `UniformDuration` facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
stream shape and inclusive point-mass no-consume semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
