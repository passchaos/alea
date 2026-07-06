# S4-M364 README WASI Dry-Run Guard

## Gap

S4-M363 added `zig build wasi-dry-run`, but README discovery was not directly
guarded by `readmecheck`. README is a first-contact command list, so the WASI
argument dry-run step should not disappear silently.

## Change

`tools/readmecheck.zig` now requires README to include:

- `zig build wasi-dry-run`

It also adds focused helper coverage showing that the WASI dry-run token is
matched exactly.

## Validation

Focused validation command:

```text
$ zig build readmecheck
readmecheck ok
```

Broader roadmap validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M364 is closed for the current bar: README WASI dry-run discovery is now
guarded by `readmecheck`. This is evidence/tooling hardening only; it does not
resolve S4-M11 and is not whole-goal completion evidence.
