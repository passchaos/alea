# S4-M1056 Seq Choice Pointer Fill Facade Direct Path

## Gap

Sequence-layer reusable `seq.Choice(T).fill` still routed through `fillFrom`.
The direct-source path already maps uniform indexes directly into the item slice
for each output; the facade path can do the same through facade `Rng`, preserving
empty-output and singleton no-consume behavior.

## Local `rand` Baseline

The local `rand` checkout remains the primary baseline for slice choice behavior.
Alea already exposes broader pointer/value/index fill surfaces than Rust's core
shape; this change tightens the reusable pointer-fill facade so it directly
drives the supplied RNG instead of bouncing through direct-source wrappers.

## Implementation

- `src/seq.zig` updates sequence-layer `Choice(T).fill` to return early for empty
  output, preserve singleton pointer `@memset`, cache the item length, and map
  direct facade-generated indexes into `*const T` outputs.
- `Choice(T).fillFrom` remains unchanged for explicit direct-source workflows.

## Validation

Focused seq Choice tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "single-item choice sampler does not consume random stream"
1/2 seq.test.single-item choice sampler does not consume random stream...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/seq.zig --test-filter "Choice value and pointer arrays mirror fills"
1/3 seq.test.Choice value and pointer arrays mirror fills...OK
2/3 seq.test.WeightedChoice value and pointer arrays mirror fills...OK
3/3 root.test_0...OK
All 3 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build statcheck && zig build test
roadmapcheck ok
statcheck ok
apicheck ok
roadmapcheck ok
readmecheck ok
examplecheck ok
toolingcheck ok
```

## Result

S4-M1056 is closed for the current bar: sequence-layer reusable `Choice(T)`
pointer fill now avoids direct-source wrapper aliases while preserving stream
shape and empty/singleton behavior. This is reliability/ergonomics work only; it
does not resolve S4-M11 and is not whole-goal completion evidence.
