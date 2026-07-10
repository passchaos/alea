# S4-M1177 Post-S4-M1176 Validate-All Refresh

## Gap

S4-M1176 added root/prelude weighted error aliases. The next stricter product
bar was to refresh the full portability-sensitive aggregate after that root API
change rather than relying only on focused native tests.

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
standard tooling/documentation gates.

## Result

S4-M1177 is closed for the current bar: the full `zig build validate-all`
aggregate passes after S4-M1176. This is broad validation evidence, not
whole-goal completion; S4-M1178 remains active.
