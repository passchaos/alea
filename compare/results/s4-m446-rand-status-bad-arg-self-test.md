# S4-M446 `rand-status` Bad-Argument Self-Test

## Gap

`rand-status --self-test` validated text, JSON, and help output, but not the
unknown-argument path. For a scripting-oriented status tool, bad arguments should
remain rejected and covered by self-tests.

## Change

`tools/rand_status.zig` now makes `--self-test` verify that an unknown argument
returns `error.UnknownArgument`. The help text now says `--self-test validates
text, JSON, help, and bad-argument paths without Rust tools`.

`docs/tooling.md` documents that scope, and `tools/toolingcheck.zig` guards the
source and docs tokens.

## Validation

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
$ zig build roadmapcheck
roadmapcheck ok
```

```text
$ git diff --check
```

## Result

S4-M446 is closed for the current bar: `rand-status` self-tests now cover the
bad-argument path. This is tooling reliability only; it does not resolve S4-M11
and is not whole-goal completion evidence.
