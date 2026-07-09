# S4-M1063 Seq WeightedChoice Checked U32 Index Sample Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).sampleIndexU32Checked` still called
`self.table.sampleU32CheckedFrom(rng)` even though the facade alias-table checked
u32 sample path is available. This left a checked u32 index sample wrapper alias
on the reusable weighted-choice facade.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes compact checked u32 weighted index sampling on reusable
sequence choices; this change tightens that facade helper so it drives the
supplied facade RNG directly through the alias-table checked u32 facade path.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).sampleIndexU32Checked` to call
  `self.table.sampleU32Checked(rng)` directly after the existing population-size
  validation.
- `WeightedChoice(T).sampleIndexU32CheckedFrom` remains unchanged for explicit
  direct-source workflows.

## Validation

Focused seq WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "WeightedChoice index arrays mirror fills"
1/2 seq.test.WeightedChoice index arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "single-positive weighted choice does not consume random stream"
1/2 seq.test.single-positive weighted choice does not consume random stream...OK
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
examplecheck ok
apicheck ok
roadmapcheck ok
```

## Result

S4-M1063 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).sampleIndexU32Checked` now avoids the direct-source wrapper
alias while preserving stream shape, population validation, and single-positive
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
