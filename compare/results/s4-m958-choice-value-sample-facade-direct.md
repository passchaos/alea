# S4-M958 Choice Value Sample Facade Direct Path

## Gap

Reusable `Choice.sampleValue` facade sampling still routed through the pointer
`sample(rng).*` wrapper. The value facade can generate the uniform index through
its facade `Rng` and copy the item directly while preserving singleton
no-consume behavior and stream shape.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows often sample copied values by sampling a
reference and cloning/copying. Alea's reusable `Choice` exposes a Zig-native value
sampler; it should sample the value directly without first constructing the
pointer path.

## Implementation

- `src/seq.zig` updates `Choice.sampleValue` to handle singleton choices without
  consuming randomness and otherwise call `Rng.uintLessThanFrom(rng, usize,
  items.len)` directly before returning the copied item.
- Focused tests cover value sample stream shape, singleton no-consume behavior,
  and facade/direct choice sampling workflows.

## Validation

Focused reusable Choice test:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
readmecheck ok
apicheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M958 is closed for the current bar: reusable `Choice.sampleValue` now avoids
the pointer sample wrapper while preserving stream shape and singleton behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
