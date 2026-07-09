# S4-M1059 Seq WeightedChoice Checked Pointer Fill Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).fillChecked` still sampled through
`self.table.sampleFrom(rng)` inside its facade checked pointer-fill loop. The
unchecked pointer fill facade already maps alias-table samples directly through
facade `Rng`, so the checked pointer fill can use the same direct facade sample
path while preserving the explicit checked API surface.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes broader reusable pointer-fill helpers than Rust's core
shape; this change tightens the checked facade pointer-fill helper so it drives
the supplied facade RNG directly instead of bouncing through direct-source
wrappers.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).fillChecked` to map
  `self.table.sample(rng)` indexes directly into item storage.
- `WeightedChoice(T).fillCheckedFrom` remains unchanged for explicit
  direct-source workflows.
- Empty-output and single-positive constant-index branches remain no-consume
  fast paths.

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
roadmapcheck ok
readmecheck ok
apicheck ok
examplecheck ok
```

## Result

S4-M1059 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).fillChecked` now avoids the direct-source wrapper alias while
preserving stream shape and empty/single-positive behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
