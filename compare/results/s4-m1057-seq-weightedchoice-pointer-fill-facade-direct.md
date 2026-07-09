# S4-M1057 Seq WeightedChoice Pointer Fill Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).fill` still routed through `fillFrom`.
The direct-source path already samples alias-table indexes directly and maps them
into item storage; the facade path can do the same through facade `Rng`,
preserving empty-output and single-positive no-consume behavior.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea already exposes broader pointer/value/index fill surfaces than
Rust's core shape; this change tightens the reusable weighted pointer-fill facade
so it directly drives the supplied RNG instead of bouncing through direct-source
wrappers.

## Implementation

- `src/seq.zig` updates sequence-layer `WeightedChoice(T).fill` to return early
  for empty output, preserve constant-index pointer `@memset`, and map direct
  facade-sampled alias-table indexes into `*const T` outputs.
- `WeightedChoice(T).fillFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq WeightedChoice tests:

```text
$ zig test src/seq.zig --test-filter "weighted choice sampler maps alias indexes to items"
1/2 seq.test.weighted choice sampler maps alias indexes to items...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "single-positive weighted choice does not consume random stream"
1/2 seq.test.single-positive weighted choice does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "WeightedChoice value and pointer arrays mirror fills"
1/2 seq.test.WeightedChoice value and pointer arrays mirror fills...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
roadmapcheck ok
examplecheck ok
readmecheck ok
toolingcheck ok
```

## Result

S4-M1057 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T)` pointer fill now avoids direct-source wrapper aliases while
preserving stream shape and empty/single-positive behavior. This is
reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
