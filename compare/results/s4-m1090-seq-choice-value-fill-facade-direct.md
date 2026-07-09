# S4-M1090 Seq Choice Value Fill Facade Direct Path

## Gap

Reusable sequence `Choice(T).fillValues` still delegated the facade value-fill
helper through `fillValuesFrom(rng, ...)`. The direct-source path already maps
sampled indexes directly into the item slice, so the facade value-fill helper can
perform the same loop with facade `Rng` instead of bouncing through the
`From` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for repeated choice
behavior. Alea exposes reusable caller-owned value fills in addition to pointer
fills; this change tightens the facade path without changing value-copy
semantics, stream shape, or singleton no-consume behavior.

## Implementation

- `src/seq.zig` updates `Choice(T).fillValues` to return early for empty output,
  preserve empty-value and singleton behavior, cache item length, and sample
  indexes directly through facade `Rng`.
- `Choice(T).fillValuesFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq Choice tests:

```text
$ zig test src/seq.zig --test-filter "Choice value and pointer arrays mirror fills"
1/3 seq.test.Choice value and pointer arrays mirror fills...OK
2/3 seq.test.WeightedChoice value and pointer arrays mirror fills...OK
3/3 root.test_0...OK
All 3 tests passed.

$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "single-item choice sampler does not consume random stream"
1/2 seq.test.single-item choice sampler does not consume random stream...OK
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
examplecheck ok
apicheck ok
readmecheck ok
```

## Result

S4-M1090 is closed for the current bar: reusable sequence `Choice(T).fillValues`
now avoids the direct-source wrapper alias while preserving stream shape,
empty-output behavior, empty-value behavior, and singleton no-consume behavior.
This is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
