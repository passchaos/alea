# S4-M1066 Seq WeightedChoice Checked Index Fill Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).fillIndicesChecked` still called the
alias-table direct-source fill path with facade `rng`. `AliasTable.fill` already
has a direct facade implementation, so the checked sequence weighted-choice
index-fill facade can call that path directly instead of bouncing through the
`fillFrom` wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes caller-owned checked weighted index fills on reusable
sequence choices; this change tightens that facade helper so it drives the
supplied facade RNG directly through the alias-table fill facade.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).fillIndicesChecked` to call
  `self.table.fill(rng, dest)` directly.
- `WeightedChoice(T).fillIndicesCheckedFrom` remains unchanged for explicit
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
apicheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
```

## Result

S4-M1066 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).fillIndicesChecked` now avoids the direct-source wrapper alias
while preserving stream shape, empty-output behavior, and single-positive
behavior. This is reliability/ergonomics work only; it does not resolve S4-M11
and is not whole-goal completion evidence.
