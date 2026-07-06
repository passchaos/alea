# S4-M439 Validate-Local Status Description

## Gap

After S4-M425..S4-M438, `zig build validate-local` includes `rand-status`,
`rand-status-json`, and `rand-status-self-test`. The build-step description still
said only "local Rust comparison and runtime checks", omitting status checks.

## Change

`build.zig` now describes `validate-local` as:

```text
Run native validation plus local Rust comparison, status, and runtime checks
```

`tools/toolingcheck.zig` now guards that description token.

## Validation

Focused validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M439 is closed for the current bar: the `validate-local` build-step
description matches its expanded comparison/status/runtime scope. This is tooling
accuracy only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
