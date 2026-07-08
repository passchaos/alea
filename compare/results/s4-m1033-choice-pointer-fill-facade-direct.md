# S4-M1033 Choice Pointer Fill Facade Direct Path

## Gap

Distribution-layer reusable `Choose(T).fill` still delegated through
`fillFrom`. The direct-source path already maps uniform indexes directly into the
item slice for each output; the facade path can do the same through facade `Rng`
while preserving empty-output and singleton no-consume behavior.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for slice choice behavior.
Alea already exposes broader pointer/value/index fill surfaces than Rust's core
shape; this change tightens the reusable pointer-fill facade so it directly
drives the supplied RNG instead of bouncing through direct-source wrappers.

## Implementation

- `src/distributions.zig` updates distribution-layer `Choose(T).fill` to return
  early for empty output, preserve singleton pointer `@memset`, cache the item
  length, and map direct facade-generated indexes into `*const T` outputs.
- `Choose(T).fillFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused Choice test:

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
examplecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1033 is closed for the current bar: distribution-layer reusable `Choose(T)`
pointer fill now avoids direct-source wrapper aliases while preserving stream
shape and empty/singleton behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
