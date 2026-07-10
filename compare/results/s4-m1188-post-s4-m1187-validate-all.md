# S4-M1188 Post-S4-M1187 Validate-All Refresh

## Gap

S4-M1187 added typed diagnostics to dynamic weighted trees, changing the public
API and storage invariants for `WeightedTree(Weight)` and `WeightedIntTree(Weight)`.
The next stricter product bar was to refresh the full portability-sensitive
validation aggregate after that code/API change instead of relying only on
focused weighted-tree tests and the local Linux `validate-local` pass.

## Validation

```text
$ git diff --check
(no output)

$ zig build rand-status-self-test
rand-status self-test ok

$ zig build roadmapcheck
roadmapcheck ok

$ zig build toolingcheck
toolingcheck ok

$ zig build validate-local
rand_distr standard-normal: 41.2 M samples/s checksum=-3.640
rand_distr standard-normal f32: 37.5 M samples/s checksum=-3.640
surfacecheck local rand: files=25 expected-tokens=75 source-tokens=137
surfacecheck local rand_core: files=6 expected-tokens=18 source-tokens=30
surfacecheck local rand_distr: files=34 expected-tokens=64 source-tokens=178
surfacecheck ok
rand_bench_smoke self-test ok
runtimecheck ok: no additional runtime runner available
rand-status self-test ok

$ zig build validate-all
roadmapcheck ok
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
run_wasi_test self-test ok
practrand self-test ok
wasi sample.wasm --flag
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

S4-M1188 is closed for the current bar: the full `zig build validate-all`
aggregate passes after S4-M1187. This is broad validation evidence, not
whole-goal completion; S4-M1189 remains active.
