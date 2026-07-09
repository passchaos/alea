# S4-M1058 Seq WeightedChoice Owned Pointer Facade Direct Path

## Gap

Sequence-layer reusable `WeightedChoice(T).ptrs` allocation-returning facade still
allocated output and filled it through `fillFrom`. The pointer fill facade now
maps alias-table samples directly through facade `Rng`, so owned pointer batches
can reuse that facade path instead of bouncing through the direct-source wrapper.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for weighted choice
behavior. Alea exposes additional allocation-returning pointer batches; this
change tightens the reusable facade owned-batch helper so it drives the supplied
facade RNG directly after allocation.

## Implementation

- `src/seq.zig` updates `WeightedChoice(T).ptrs` to allocate the pointer slice and
  call `self.fill(rng, out)` directly.
- `WeightedChoice(T).ptrsFrom` remains unchanged for explicit direct-source
  workflows.

## Validation

Focused seq WeightedChoice tests:

```text
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
roadmapcheck ok
readmecheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M1058 is closed for the current bar: sequence-layer reusable
`WeightedChoice(T).ptrs` now avoids the direct-source wrapper alias while
preserving allocation ownership, stream shape, and single-positive behavior. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
