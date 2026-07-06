# S4-M404 README WASI Self-Test Prose Guard

## Gap

README explains `zig build wasi-self-test`, but readmecheck only required the
command name and generic dry-run/no-execution tokens. It did not guard the
stronger meaning that the self-test checks the Node WASI runner dry-run and
missing-argument paths without wasm.

## Change

`tools/readmecheck.zig` now requires README to contain:

```text
Node WASI runner dry-run and missing-argument paths without wasm
```

The WASI dry-run helper test now includes this stronger self-test prose and
verifies the token.

## Validation

Focused validation commands:

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M404 is closed for the current bar: README keeps the no-wasm WASI runner
self-test semantics visible, and readmecheck guards them. This is portability
documentation reliability only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
