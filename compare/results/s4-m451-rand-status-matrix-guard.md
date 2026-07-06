# S4-M451 `rand-status` Command Matrix Guard

## Gap

S4-M450 recorded a fresh command-matrix run for all `rand-status` modes. The
matrix evidence itself needed a guard so future edits do not silently drop text,
JSON, schema-version, self-test, help, or non-completion signals.

## Change

`tools/roadmapcheck.zig` now reads
`compare/results/s4-m450-rand-status-command-matrix.md` and requires tokens for:

- `zig build rand-status`
- `zig build rand-status-json`
- `zig build rand-status-schema-version`
- `zig build rand-status-self-test`
- `zig build rand-status -- --help`
- JSON boolean/schema fields
- help text for schema-version and self-test
- non-completion language referencing S4-M11

## Validation

Focused validation commands:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M451 is closed for the current bar: the `rand-status` command matrix evidence
is guarded. This is evidence-quality maintenance only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
