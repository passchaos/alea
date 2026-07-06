# S4-M335 Validate Aggregate Dependency Guard

## Gap

`zig build validate` is Alea's broad native validation gate. Before S4-M335,
`toolingcheck` only guarded one part of that aggregate directly: the
`doccheck_step` dependency. A future build edit could accidentally drop another
current validation branch — examples, statistical checks, distribution checks,
libc-backed distribution checks, or accepted-profile checks — while the tooling
catalog still described `validate` as broad native validation.

This is important while comparing against local Rust `rand` / `rand_distr`
because broad validation evidence is only useful if the aggregate continues to
run all intended local checks.

## Change

`tools/toolingcheck.zig` now checks the full current `validate` dependency set:

- `validate_step.dependOn(&run_tests.step)`
- `validate_step.dependOn(examples_step)`
- `validate_step.dependOn(doccheck_step)`
- `validate_step.dependOn(&run_statcheck.step)`
- `validate_step.dependOn(&run_distcheck.step)`
- `validate_step.dependOn(&run_distcheck_libc.step)`
- `validate_step.dependOn(&run_profilecheck.step)`

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

S4-M335 is closed for the current bar: the native validation aggregate is now
checked by tooling rather than only documented. This is validation/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
