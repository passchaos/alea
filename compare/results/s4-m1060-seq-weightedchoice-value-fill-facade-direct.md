# S4-M1060 Seq WeightedChoice Value Fill Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).fillValues` still delegated facade
value fills through `fillValuesFrom`. The pointer fill facade already maps
alias-table samples directly through facade `Rng`, so value fills can use the
same direct facade sample path instead of bouncing through the direct-source
wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes reusable owned/caller-owned weighted value batches beyond
Rust's core shape; this change tightens the facade value-fill helper so it drives
the supplied facade RNG directly.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).fillValues` to return early for empty
  output, preserve empty-enum and constant-index behavior, and map
  `self.table.sample(rng)` indexes directly into value outputs.
- `WeightedChoice(T).fillValuesFrom` remains unchanged for explicit direct-source
  workflows.

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
toolingcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
```

## Result

S4-M1060 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).fillValues` now avoids the direct-source wrapper alias while
preserving stream shape and empty/single-positive behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
