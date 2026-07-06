# S4-M363 WASI Dry-Run Build Step

## Gap

S4-M362 added `tools/run_wasi_test.js --dry-run`, but users still had to know the
script invocation. A project build step makes WASI runner argument validation
discoverable via `zig build -l` and guardable by `toolingcheck`.

## Change

`build.zig` now adds:

```text
zig build wasi-dry-run
```

When Node is available, the step runs:

```text
node --no-warnings tools/run_wasi_test.js --dry-run sample.wasm --flag
```

If Node is missing, the step shares the existing WASI missing-node failure path.
README, `docs/api-reference.md`, and `docs/tooling.md` list the step.
`tools/toolingcheck.zig` guards the build-step and dependency tokens.

## Validation

Focused validation command:

```text
$ zig build wasi-dry-run
wasi sample.wasm --flag
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M363 is closed for the current bar: WASI runner dry-run validation is
available through a discoverable build step. This is evidence/tooling hardening
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
