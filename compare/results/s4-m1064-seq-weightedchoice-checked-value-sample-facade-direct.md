# S4-M1064 Seq WeightedChoice Checked Value Sample Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).sampleValueChecked` still called
`self.table.sampleCheckedFrom(rng)` even though the facade alias-table checked
sample path is available. This left a checked weighted value sample wrapper alias
after the direct checked value-fill work.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes explicit checked weighted value sampling on reusable
sequence choices; this change tightens that facade helper so it drives the
supplied facade RNG directly through the alias-table checked facade path.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).sampleValueChecked` to call
  `self.table.sampleChecked(rng)` directly after preserving empty-enum
  validation.
- `WeightedChoice(T).sampleValueCheckedFrom` remains unchanged for explicit
  direct-source workflows.

## Validation

Focused seq WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "WeightedChoice value and pointer arrays mirror fills"
1/2 seq.test.WeightedChoice value and pointer arrays mirror fills...OK
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
apicheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
roadmapcheck ok
```

## Result

S4-M1064 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).sampleValueChecked` now avoids the direct-source wrapper alias
while preserving stream shape, empty-enum validation, and single-positive
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
