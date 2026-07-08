# S4-M956 Choice Sample Facade Direct Path

## Gap

Reusable `Choice.sample` still routed through the direct-source `sampleFrom`
wrapper. The facade sample helper can generate the uniform index through its
facade `Rng` and map directly into item storage while preserving singleton
no-consume behavior and stream shape.

## Local `rand` Baseline

Local Rust `rand` slice-choice workflows sample references directly from an RNG
reference. Alea's reusable `Choice` facade should mirror that direct workflow
without routing through a direct-source wrapper.

## Implementation

- `src/seq.zig` updates `Choice.sample` to handle singleton choices without
  consuming randomness and otherwise call `Rng.uintLessThanFrom(rng, usize,
  items.len)` directly before mapping to `*const T`.
- Focused tests cover pointer sample stream shape, singleton no-consume behavior,
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
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M956 is closed for the current bar: reusable `Choice.sample` now avoids the
`sampleFrom` wrapper while preserving stream shape and singleton behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
