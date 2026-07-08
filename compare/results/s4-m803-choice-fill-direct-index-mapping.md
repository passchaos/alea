# S4-M803 Choice Fill Direct Index Mapping

## Gap

S4-M795 optimized uniform choice probability fills, while repeated unweighted
choice pointer/value fills still routed each output slot through
`sampleFrom` / `sampleValueFrom`. Those wrappers reloaded the item slice and
choice length for every output even though fill paths can generate an index and
map it directly into the same item storage.

## Local `rand` Baseline

The local Rust checkout (`/home/passchaos/Work/rand/src/seq/slice.rs`) implements
`choose_iter` as `rng.sample_iter(Uniform::new(0, self.len()).ok()?).map(|i|
&self[i])`: a uniform index stream mapped directly into the backing slice. Alea
keeps its Zig-native caller-owned pointer/value fill helpers and applies the
same direct index-to-item mapping policy to bulk fills.

## Implementation

- `src/seq.zig` updates reusable `Choice.fillFrom` and `Choice.fillValuesFrom`
  to cache the item slice/length once per fill and map generated indexes
  directly to pointers or copied values.
- `src/distributions.zig` mirrors the same direct index mapping for
  distribution-layer `Choose.fillFrom` and `Choose.fillValuesFrom`.
- Singleton and zero-length-output no-consumption behavior is preserved.
- Focused tests compare pointer/value fills against index fills with identical
  seeds for reusable `Choice` and distribution-layer `Choose`, proving stream
  shape and mapping semantics stay aligned.

## Validation

Focused sequence and distribution tests:

```text
$ zig test src/seq.zig --test-filter "choice sampler repeatedly samples slice references"
1/2 seq.test.choice sampler repeatedly samples slice references...OK
2/2 root.test_0...OK
All 2 tests passed.

$ zig test src/distributions.zig --test-filter "distribution Choose sampler mirrors slice choices"
1/2 distributions.test.distribution Choose sampler mirrors slice choices...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
examplecheck ok
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M803 is closed for the current bar: reusable `Choice` and distribution-layer
`Choose` pointer/value fills now avoid per-slot sample wrapper calls and map
generated indexes directly into item storage while preserving stream shape. This
is reliability/ergonomics work only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
