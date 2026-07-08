# S4-M994 UniformUnicodeScalar Facade Direct Paths

## Gap

Reusable `UniformUnicodeScalar.sample` and `UniformUnicodeScalar.fill` facade
helpers still routed through `sampleFrom` / `fillFrom` wrappers. The sampler
already stores whether the scalar range is half-open or inclusive, so facade calls
can dispatch directly through facade `Rng` Unicode scalar range helpers while
preserving surrogate-gap and point-mass behavior.

## Local `rand` Baseline

Local Rust `rand` exposes `UniformChar` for Unicode scalar sampling through RNG
reference entry points. Alea's `UniformUnicodeScalar` / `UniformChar` sampler is
Zig-native over `u21` scalar values and should drive facade `Rng` directly instead
of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `UniformUnicodeScalar.sample` to call facade
  `rng.unicodeScalarRangeLessThan` or `rng.unicodeScalarRangeAtMost` directly.
- `src/distributions.zig` updates `UniformUnicodeScalar.fill` to call facade
  `rng.fillUnicodeScalarRangeLessThan` or `rng.fillUnicodeScalarRangeAtMost`
  directly.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows.

## Validation

Focused UniformUnicodeScalar test:

```text
$ zig test src/distributions.zig --test-filter "UniformUnicodeScalar sampler mirrors unicode range helpers"
1/2 distributions.test.UniformUnicodeScalar sampler mirrors unicode range helpers...OK
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

S4-M994 is closed for the current bar: reusable `UniformUnicodeScalar` facade
sample/fill helpers now avoid direct-source wrapper aliases while preserving
Unicode scalar range semantics, surrogate-gap handling, stream shape, and
inclusive point-mass behavior. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
