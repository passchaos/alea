# S4-M389 Validate-All Refresh After WASI Aggregate Expansion

## Gap

S4-M388 changed `zig build validate-all` so the portability-sensitive aggregate
now includes `wasi-dry-run` and `wasi-self-test` in addition to native
validation, crosscheck, `test-wasi`, and `wasi-report`. The expanded aggregate
needed a real full run recorded as evidence.

## Validation

Command:

```text
$ zig build validate-all
```

Observed key output:

```text
run_wasi_test self-test ok
wasi sample.wasm --flag
...
toolingcheck ok
readmecheck ok
roadmapcheck ok
apicheck ok
examplecheck ok
profilecheck ok
profiletailcheck ok
profilestresscheck ok
profilelongcheck ok
```

The command completed successfully. The output shows that the newly included
WASI self-test and dry-run paths ran before the rest of the native, cross-target,
WASI unit, and WASI report validation completed.

## Result

S4-M389 is closed for the current bar: the expanded `validate-all` aggregate
passes with the new WASI dry/self-test coverage. This is portability validation
evidence only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
