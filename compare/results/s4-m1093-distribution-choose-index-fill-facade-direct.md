# S4-M1093 Distribution Choose Index Fill Facade Direct Path

## Gap

Distribution-layer reusable `Choose(T).fillIndices` still delegated the facade
index-fill helper through `fillIndicesFrom(rng, ...)`. The direct-source path
already caches item length and generates indexes directly, so the facade index
fill helper can perform the same loop with facade `Rng` instead of bouncing
through the `From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for repeated choice index
behavior. Alea exposes reusable distribution-layer index fills mirroring the
sequence-layer choice surface; this change tightens the facade path without
changing index output semantics, stream shape, or singleton no-consume behavior.

## Implementation

- `src/distributions.zig` updates `Choose(T).fillIndices` to return early for
  empty output, preserve singleton behavior, cache item length, and sample
  indexes directly through facade `Rng`.
- `Choose(T).fillIndicesFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused distribution Choose tests:

```text
$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
apicheck ok
```

## Result

S4-M1093 is closed for the current bar: distribution-layer `Choose(T).fillIndices`
now avoids the direct-source wrapper alias while preserving stream shape,
empty-output behavior, and singleton no-consume behavior. This is reliability /
ergonomics work only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
