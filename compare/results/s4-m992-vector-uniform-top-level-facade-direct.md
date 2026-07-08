# S4-M992 VectorUniform Top-Level Facade Direct Paths

## Gap

Top-level vector Uniform facade helpers still routed through direct-source
`From` wrappers. S4-M991 made reusable `VectorUniform` facade sample/fill paths
direct; the top-level vector half-open and inclusive helpers can now dispatch
directly through facade `Rng` vector range logic while preserving checked
validation and zero-length checked-fill behavior.

## Local `rand` Baseline

Local Rust `rand` range sampling APIs operate directly from an RNG reference.
Alea extends this with Zig-native vector half-open and inclusive range helpers;
top-level vector facade calls should drive the facade `Rng` directly instead of
bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `vectorUniform`, `vectorUniformChecked`,
  `fillVectorUniform`, and `fillVectorUniformChecked` to dispatch directly
  through facade `Rng` vector half-open range helpers.
- `src/distributions.zig` updates `vectorUniformInclusive`,
  `vectorUniformInclusiveChecked`, `fillVectorUniformInclusive`, and
  `fillVectorUniformInclusiveChecked` to dispatch directly through facade `Rng`
  inclusive integer helpers or closed-unit floating-point vector loops.
- Checked inclusive fill keeps the existing zero-length fast path so empty
  destinations neither validate range endpoints nor consume random input.

## Validation

Focused vector Uniform tests:

```text
$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "invalid uniform distribution helpers do not consume random stream"
1/2 distributions.test.invalid uniform distribution helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate uniform distribution helpers do not consume random stream"
1/2 distributions.test.degenerate uniform distribution helpers do not consume random stream...OK
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
roadmapcheck ok
apicheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M992 is closed for the current bar: top-level vector Uniform facade helpers now
avoid direct-source wrapper aliases while preserving vector lane stream shape,
inclusive endpoint behavior, invalid-range no-consume behavior, and zero-length
checked fill semantics. This is reliability/ergonomics work only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
