# S4-M1190 Post-S4-M1189 Validate-All Refresh

## Gap

S4-M1189 added typed total-weight diagnostics to `WeightedTree(Weight)` and
`WeightedIntTree(Weight)`, extending the dynamic weighted-tree public API after
S4-M1187's typed weight sidecar work. The next stricter product bar was to
refresh the full portability-sensitive validation aggregate after that code/API
change instead of relying only on focused weighted-tree tests and the local
Linux `validate-local` pass.

## Validation

```text
$ zig build validate-all
roadmapcheck ok
apicheck ok
toolingcheck ok
readmecheck ok
examplecheck ok
run_wasi_test self-test ok
wasi sample.wasm --flag
practrand self-test ok
statcheck ok
distcheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok
```

The full output is long; the important coverage signals are native validation,
cross-target compile checks, Node WASI unit/dry/self-test coverage, the chained
WASI report, accepted vector-profile checks through `profilelongcheck ok`, and
the standard tooling/documentation gates. The retained long-profile tail includes:

```text
VectorStandardNormalTableF32 long aggregate: seeds=8 lanes=8388608 mean=-0.00002687 variance=0.99966339 max_abs=4.00877237
VectorStandardNormalTableF64 long aggregate: seeds=8 lanes=8388608 mean=-0.00005080 variance=0.99902498 max_abs=4.00877259
VectorStandardExponentialTableF32 long aggregate: seeds=8 lanes=8388608 mean=1.00022063 variance=1.00161240 min=0.00003052 max=10.39720726
VectorStandardExponentialTableF64 long aggregate: seeds=8 lanes=8388608 mean=1.00004324 variance=0.99999883 min=0.00003052 max=10.39720771
profilelongcheck ok
```

## Result

S4-M1190 is closed for the current bar: the full `zig build validate-all`
aggregate passes after S4-M1189. This is broad validation evidence, not
whole-goal completion; S4-M1191 remains active.
