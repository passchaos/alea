# S4-M376 WASI Runner File-Input Guard

## Gap

`tools/run_wasi_test.js` is used by `zig build test-wasi`, `zig build
wasi-dry-run`, and the generic `wasi-*` report tool steps. These build steps
should register the script as an input so changes to the runner are visible to
the build graph.

## Change

`tools/toolingcheck.zig` now verifies `build.zig` contains file-input tokens for:

- `run_wasi_tests.addFileInput(b.path("tools/run_wasi_test.js"))`
- `wasi_dry_run.addFileInput(b.path("tools/run_wasi_test.js"))`
- `run_tool.addFileInput(b.path("tools/run_wasi_test.js"))`

`docs/tooling.md` now notes that toolingcheck guards WASI runner file inputs.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Broader roadmap validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M376 is closed for the current bar: WASI runner script inputs are now guarded
for the relevant build steps. This is evidence/tooling hardening only; it does
not resolve S4-M11 and is not whole-goal completion evidence.
