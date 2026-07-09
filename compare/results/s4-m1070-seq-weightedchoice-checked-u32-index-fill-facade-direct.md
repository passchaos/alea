# S4-M1070 Seq WeightedChoice Checked U32 Index Fill Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).fillIndicesU32Checked` still called
`self.table.fillU32CheckedFrom(rng, dest)` after population validation. Reusable
`AliasTable.fillU32Checked` now has a direct facade implementation, so the checked
sequence weighted-choice u32 index-fill facade can call that checked u32 facade
directly instead of bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes compact caller-owned checked u32 weighted index fills on
reusable sequence choices; this change tightens that facade helper so it drives
the supplied facade RNG directly through the alias-table checked u32 fill facade.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).fillIndicesU32Checked` to call
  `self.table.fillU32Checked(rng, dest)` after the existing population-size
  validation.
- `WeightedChoice(T).fillIndicesU32CheckedFrom` remains unchanged for explicit
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
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
```

## Result

S4-M1070 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).fillIndicesU32Checked` now avoids the direct-source wrapper
alias while preserving stream shape, population validation, empty-output
behavior, and single-positive behavior. This is reliability/ergonomics work only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
