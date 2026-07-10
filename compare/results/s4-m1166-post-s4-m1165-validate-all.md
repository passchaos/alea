# S4-M1166 Post-S4-M1165 Validate-All Refresh

## Gap

S4-M1165 changed `WeightedIntTree(Weight)` integer overflow diagnostics to match
local `rand_distr::weighted::WeightedTreeIndex` for otherwise representable
integer total overflow. The next stricter bar is broader validation evidence:
prove the latest local Rust compatibility changes still pass the full native,
cross-target, and WASI validation aggregate, then raise the roadmap again.

## Validation

S4-M1166 ran the full portability-sensitive aggregate:

```text
$ zig build validate-all
wasi sample.wasm --flag
roadmapcheck ok
toolingcheck ok
examplecheck ok
readmecheck ok
statcheck ok
apicheck ok
run_wasi_test self-test ok
practrand self-test ok
distcheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok
```

The command completed with exit code 0. Since `validate-all` depends on native
`validate`, `crosscheck`, `test-wasi`, `wasi-dry-run`, `wasi-self-test`, and the
chained WASI report, this refresh covers:

- native unit/doc/example/API/stat/dist/profile validation;
- local roadmap/tooling guards;
- cross-target compile checks;
- Node WASI unit execution;
- Node WASI dry-run and runner self-test paths;
- WASI repro/statcheck/distcheck/profilecheck/profiletailcheck/
  profilestresscheck/profilelongcheck chain.

Representative final WASI/profile output included:

```text
VectorStandardExponentialApproxLogF32 long aggregate: seeds=8 lanes=8388608 mean=0.99958611 variance=0.99853514 min=-0.00000000 max=17.32868004
  tail(x>=4.0)=0.01828253 expected=0.01831564
  tail(x>=6.0)=0.00244248 expected=0.00247875
  tail(x>=8.0)=0.00033665 expected=0.00033546
  tail(x>=10.0)=0.00004530 expected=0.00004540
profilelongcheck ok
```

## Result

S4-M1166 is closed for the current bar: the post-S4-M1165 tree-overflow changes
pass the full `validate-all` aggregate, including native, cross-target, and WASI
coverage. This is not whole-goal completion; S4-M1167 remains active.
