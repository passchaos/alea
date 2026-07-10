# S4-M1181 Post-S4-M1180 Validate-All Refresh

## Gap

S4-M1180 added typed static weighted diagnostics to `AliasTable(Weight)` /
`WeightedIndex(Weight)` after several weighted API and local Rust comparison
updates. The next stricter product bar was to refresh the full
portability-sensitive validation aggregate after that code/API change rather
than relying only on focused weighted tests and `validate-local` evidence.

## Validation

```text
$ zig build validate-all
run_wasi_test self-test ok
wasi sample.wasm --flag
readmecheck ok
apicheck ok
statcheck ok
distcheck ok
toolingcheck ok
roadmapcheck ok
examplecheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok
```

The full output is long; the important coverage signals are native validation,
cross-target compile checks, Node WASI unit/dry/self-test coverage, the chained
WASI report, accepted profile checks through `profilelongcheck ok`, and the
standard tooling/documentation gates. The retained output also includes the
long-profile aggregate tail checks, for example:

```text
VectorStandardNormalTableF32 long aggregate: seeds=8 lanes=8388608 mean=-0.00002687 variance=0.99966339 max_abs=4.00877237
VectorStandardNormalTableF64 long aggregate: seeds=8 lanes=8388608 mean=-0.00005080 variance=0.99902498 max_abs=4.00877259
VectorStandardExponentialTableF32 long aggregate: seeds=8 lanes=8388608 mean=1.00022063 variance=1.00161240 min=0.00003052 max=10.39720726
VectorStandardExponentialTableF64 long aggregate: seeds=8 lanes=8388608 mean=1.00004324 variance=0.99999883 min=0.00003052 max=10.39720771
profilelongcheck ok
```

## Result

S4-M1181 is closed for the current bar: the full `zig build validate-all`
aggregate passes after S4-M1180. This is broad validation evidence, not
whole-goal completion; S4-M1182 remains active.
