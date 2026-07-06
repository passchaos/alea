# S4-M359 README PractRand Dry-Run Guard

## Gap

S4-M357 and S4-M358 made the PractRand pipeline easier to validate without
`RNG_test`, but README discovery was not directly guarded by `readmecheck`. README
is a first-contact document, so it should keep the dry-run command, build step,
and custom binary environment variable visible.

## Change

`tools/readmecheck.zig` now requires README to include:

- `tools/practrand.sh --dry-run`
- `zig build practrand-dry-run`
- `PRACTRAND_BIN`

It also adds focused helper coverage showing those tokens are detected together.

## Validation

Focused validation command:

```text
$ zig build readmecheck
readmecheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M359 is closed for the current bar: README PractRand dry-run and custom-binary
guidance is now guarded by `readmecheck`. This is evidence/tooling hardening
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
