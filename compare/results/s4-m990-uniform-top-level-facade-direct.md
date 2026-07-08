# S4-M990 Uniform Top-Level Facade Direct Paths

## Gap

Scalar top-level Uniform facade helpers still routed through direct-source
wrappers. S4-M989 made reusable `Uniform(T)` facade sample/fill paths direct; the
scalar top-level half-open and inclusive helpers can now dispatch directly through
facade `Rng` range logic while preserving checked validation and zero-length
checked-fill behavior.

## Local `rand` Baseline

Local Rust `rand` range sampling APIs operate directly from an RNG reference.
Alea's scalar top-level uniform helpers cover both half-open and inclusive
integer/float ranges; facade calls should drive the facade `Rng` directly instead
of bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `uniform`, `uniformChecked`, `fillUniform`, and
  `fillUniformChecked` to dispatch directly through facade `Rng` half-open range
  helpers.
- `src/distributions.zig` updates `uniformInclusive`, `uniformInclusiveChecked`,
  `fillUniformInclusive`, and `fillUniformInclusiveChecked` to dispatch directly
  through facade `Rng` inclusive integer helpers or closed-unit floating-point
  loops.
- Checked inclusive fill keeps the existing zero-length fast path so empty
  destinations neither validate range endpoints nor consume random input.

## Validation

Focused Uniform tests:

```text
$ zig test src/distributions.zig --test-filter "basic distributions stay in expected ranges"
1/2 distributions.test.basic distributions stay in expected ranges...OK
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

$ zig test src/distributions.zig --test-filter "zero-length base distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length base distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M990 is closed for the current bar: scalar top-level Uniform facade helpers now
avoid direct-source wrapper aliases while preserving stream shape, inclusive
endpoint behavior, invalid-range no-consume behavior, and zero-length checked fill
semantics. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
