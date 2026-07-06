# S4-M391 Validate PractRand Wrapper Self-Test

## Gap

S4-M386 added `zig build practrand-self-test`, but ordinary native
`zig build validate` did not run it. Since the self-test does not require
external PractRand, broad native validation can cheaply cover PractRand wrapper
command construction and argument diagnostics.

## Change

`build.zig` now makes `zig build validate` depend on `zig build
practrand-self-test`. The tooling catalog, README, core guide, and API reference
now state that broad native validation includes this no-external PractRand
wrapper self-test. `tools/toolingcheck.zig` guards the aggregate dependency and
documentation tokens.

## Validation

Focused validation commands:

```text
$ zig build practrand-self-test
practrand self-test ok
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

## Result

S4-M391 is closed for the current bar: broad native validation now includes the
no-external PractRand wrapper self-test. This is external statistical tooling
reliability only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
