# S4-M805 AliasTable Fill Direct Sampling Paths

## Gap

S4-M796 optimized AliasTable weight/probability iterator fills, but caller-owned
index fills still routed each slot through `AliasTable.sampleFrom`. That wrapper
rechecked constant-index/power-of-two/general sampling branches per output slot.

## Local `rand` Baseline

Rust weighted-index sampling centers on a weighted-index distribution sampled in
loops by callers or `sample_iter` users. Alea already exposes caller-owned
AliasTable `fill` APIs; this milestone keeps those Zig-native bulk APIs and
applies the alias-table branch once per fill, then runs the selected sampling
loop directly.

## Implementation

- `src/distributions.zig` updates `AliasTable.fillFrom` to return immediately
  for empty outputs, keep constant-index no-consumption behavior, then run either
  the power-of-two one-word alias loop or the general column/probability loop
  directly into `usize` output.
- `src/distributions.zig` mirrors the same direct loops in `fillU32CheckedFrom`
  after compact-width validation.
- Focused tests compare direct fills with scalar `sampleFrom` /
  `sampleU32CheckedFrom` loops for both power-of-two and non-power-of-two alias
  table sizes, proving stream shape and output mapping remain aligned.

## Validation

Focused distribution test:

```text
$ zig test src/distributions.zig --test-filter "alias table exposes totals"
1/2 distributions.test.alias table exposes totals and reconstructs weights...OK
2/2 root.test_0...OK
All 2 tests passed.
```

Broader validation for the committed change:

```text
$ zig build roadmapcheck && git diff --check && zig build test
roadmapcheck ok
readmecheck ok
examplecheck ok
roadmapcheck ok
apicheck ok
toolingcheck ok
```

## Result

S4-M805 is closed for the current bar: static AliasTable usize/u32 index fills
now avoid per-slot `sampleFrom` wrapper calls and run direct alias sampling loops
while preserving stream shape. This is reliability/ergonomics work only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
