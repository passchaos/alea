# S4-M337 WASI Report Chain Dependency Guard

## Gap

`zig build wasi-report` is the checked-in wasm32-wasi evidence chain used by
`zig build validate-all`. Before S4-M337, tooling checks verified that the WASI
steps existed and that `validate-all` depended on `wasi-report`, but they did not
verify the internal chain connecting repro, statcheck, distcheck, profilecheck,
tail, stress, and long-profile WASI checks. A future build edit could silently
skip one branch while leaving the public aggregate command intact.

This matters for Alea's long-term portability bar: Linux remains first, but WASI
is the currently available second runtime evidence path. Its aggregate should be
guarded just like native validation aggregates.

## Change

`tools/toolingcheck.zig` now checks the current `wasi-report` chain tokens:

- `wasi_statcheck.step.dependOn(&wasi_repro.step)`
- `wasi_distcheck.step.dependOn(&wasi_statcheck.step)`
- `wasi_profilecheck.step.dependOn(&wasi_distcheck.step)`
- `wasi_profiletailcheck.step.dependOn(&wasi_profilecheck.step)`
- `wasi_profilestresscheck.step.dependOn(&wasi_profiletailcheck.step)`
- `wasi_profilelongcheck.step.dependOn(&wasi_profilestresscheck.step)`
- `wasi_report_step.dependOn(&wasi_profilelongcheck.step)`
- `wasi_report_step.dependOn(&node_missing.step)`

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

S4-M337 is closed for the current bar: the WASI report chain and no-Node failure
path are now checked by tooling. This is portability-validation tooling hardening
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
