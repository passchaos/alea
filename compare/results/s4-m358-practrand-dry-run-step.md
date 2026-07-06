# S4-M358 PractRand Dry-Run Build Step

## Gap

S4-M357 added `tools/practrand.sh --dry-run`, but users still had to know the
script path. A project build step makes the dry-run pipeline discoverable via
`zig build -l` and guardable by `toolingcheck`.

## Change

`build.zig` now adds:

```text
zig build practrand-dry-run
```

The step runs:

```text
tools/practrand.sh --dry-run fast 1048576
```

Documentation now lists the step in README, `docs/core-guide.md`,
`docs/api-reference.md`, and `docs/tooling.md`. `tools/toolingcheck.zig` guards
the build step and system-command dependency tokens.

## Validation

Focused validation command:

```text
$ zig build practrand-dry-run
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 1048576 | RNG_test stdin64
```

Broader validation commands:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M358 is closed for the current bar: PractRand pipeline dry-run validation is
available through a discoverable build step. This is evidence/tooling hardening
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
