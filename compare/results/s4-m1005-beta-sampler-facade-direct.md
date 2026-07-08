# S4-M1005 Beta Sampler Facade Direct Paths

## Gap

Reusable scalar `Beta(T).sample` and `Beta(T).fill` facade helpers still routed
through `sampleFrom` / `fillFrom` wrappers. S4-M874 made the direct-source fill
path draw cached Gamma samplers directly; the facade sample/fill paths can now
execute the same point-mass, uniform, square-root, and generic Gamma-ratio paths
directly through facade `Rng`.

## Local `rand` Baseline

Local Rust `rand_distr` `Beta` reusable samplers sample directly from an RNG
reference. Alea's reusable scalar Beta facade should likewise drive facade `Rng`
directly rather than bouncing through direct-source aliases.

## Implementation

- `src/distributions.zig` updates `Beta(T).sample` to execute point-zero,
  point-one, uniform, square-root edge, and generic cached-Gamma-ratio paths
  directly through facade `Rng`.
- `src/distributions.zig` updates `Beta(T).fill` to fill point-mass buffers,
  uniform buffers, square-root edge buffers, and generic Gamma-ratio values
  directly through facade `Rng` instead of delegating to `fillFrom`.
- Direct-source `sampleFrom` / `fillFrom` remain unchanged for explicit
  direct-source workflows and vector/top-level composition helpers.

## Validation

Focused Beta/Gamma tests:

```text
$ zig test src/distributions.zig --test-filter "non-uniform samplers can be reused with sample iterators"
1/2 distributions.test.non-uniform samplers can be reused with sample iterators...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution vector helpers preserve support and stream shape"
1/2 distributions.test.distribution vector helpers preserve support and stream shape...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "degenerate gamma helpers do not consume random stream"
1/2 distributions.test.degenerate gamma helpers do not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "zero-length core continuous distribution fills do not validate or consume random stream"
1/2 distributions.test.zero-length core continuous distribution fills do not validate or consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M1005 is closed for the current bar: reusable scalar Beta facade sample/fill
helpers now avoid direct-source wrapper aliases while preserving stream shape,
point-mass no-consume behavior, and zero-length checked fill semantics. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
