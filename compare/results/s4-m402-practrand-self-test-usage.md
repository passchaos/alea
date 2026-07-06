# S4-M402 PractRand Self-Test Usage Prose

## Gap

`tools/practrand.sh --self-test` exists and is wired into validation, but the
wrapper help only listed the command in examples. It did not explain that the
self-test validates dry-run command construction without requiring external
`RNG_test`.

## Change

`tools/practrand.sh --help` now includes a self-test section:

```text
--self-test validates dry-run command construction without requiring RNG_test.
```

`tools/toolingcheck.zig` guards this script token.

## Validation

Focused validation commands:

```text
$ tools/practrand.sh --help
...
Self-test:
  --self-test validates dry-run command construction without requiring RNG_test.
```

```text
$ tools/practrand.sh --self-test
practrand self-test ok
```

```text
$ zig build toolingcheck
toolingcheck ok
```

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M402 is closed for the current bar: the PractRand wrapper help explains the
no-`RNG_test` self-test semantics, and toolingcheck guards the text. This is
external statistical tooling reliability only; it does not resolve S4-M11 and is
not whole-goal completion evidence.
