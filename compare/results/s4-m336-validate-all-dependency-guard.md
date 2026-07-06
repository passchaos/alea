# S4-M336 Validate-All Aggregate Dependency Guard

## Gap

`zig build validate-all` is Alea's broadest checked-in validation aggregate: it
combines native validation with cross-target compile checks and WASI runtime
execution. Before S4-M336, `toolingcheck` verified that the step existed and that
its command was documented, but it did not directly guard each aggregate branch.
A future build edit could accidentally drop crosscheck, test-wasi, or the WASI
report chain while docs still presented `validate-all` as the broad validation
command.

This matters because portability evidence is one of the long-term product tracks
for surpassing local Rust `rand` / `rand_distr`: native Linux is first, but the
broader validation aggregate should remain trustworthy as the bar rises.

## Change

`tools/toolingcheck.zig` now checks the full current `validate-all` dependency
set:

- `validate_all_step.dependOn(validate_step)`
- `validate_all_step.dependOn(crosscheck_step)`
- `validate_all_step.dependOn(wasi_test_step)`
- `validate_all_step.dependOn(wasi_report_step)`

`docs/tooling.md` now describes this aggregate dependency guard as part of
`zig build toolingcheck`.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
examplecheck ok
```

## Result

S4-M336 is closed for the current bar: `validate-all` is now checked for native,
cross-target, WASI unit, and WASI report coverage rather than only documented.
This is portability-validation tooling hardening only; it does not resolve S4-M11
and is not whole-goal completion evidence.
