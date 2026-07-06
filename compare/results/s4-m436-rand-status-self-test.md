# S4-M436 `rand-status` Self-Test Step

## Gap

`rand-status` had helper tests and JSON/help output, but there was no direct
runtime self-test command for validating text, JSON, and help output without
invoking Rust comparison tools. `validate-local` also did not exercise such a
runtime self-test path.

## Change

- `tools/rand_status.zig` now supports `--self-test`, validating text, JSON, and
  help output and printing `rand-status self-test ok`.
- `build.zig` adds `zig build rand-status-self-test` and includes it in
  `validate-local`.
- README, core guide, API reference, and tooling docs mention the self-test path.
- `tools/readmecheck.zig` and `tools/toolingcheck.zig` guard the command,
  dependency shape, source tokens, and docs tokens.

## Validation

Observed self-test output:

```text
$ zig build rand-status-self-test
rand-status self-test ok
```

Focused validation commands:

```text
$ zig build rand-status-self-test
rand-status self-test ok
```

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build readmecheck
readmecheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M436 is closed for the current bar: `rand-status` has a direct self-test and
`validate-local` includes it. This is local comparison tooling reliability only;
it does not resolve S4-M11 and is not whole-goal completion evidence.
