# S4-M357 PractRand Wrapper Dry-Run

## Gap

`tools/practrand.sh` wraps `zig build stream` and `RNG_test stdin64` for external
statistical evidence. Before S4-M357, the wrapper could not be validated on a
machine without PractRand installed, and users with differently named PractRand
binaries had to edit the script or PATH.

## Change

`tools/practrand.sh` now supports:

- `--help` usage text;
- `--dry-run` to print the exact pipeline without requiring PractRand;
- `PRACTRAND_BIN` to select an executable name other than `RNG_test`;
- argument-count validation;
- clearer missing-binary diagnostics including dry-run guidance.

README, `docs/core-guide.md`, `docs/api-reference.md`, and `docs/tooling.md` now
mention the dry-run path. `tools/toolingcheck.zig` guards the documentation and
script tokens.

## Validation

Focused validation command:

```text
$ tools/practrand.sh --dry-run default 1048576
zig build -Doptimize=ReleaseFast stream -- --engine default --bytes 1048576 | RNG_test stdin64
```

Custom binary dry-run:

```text
$ PRACTRAND_BIN=/tmp/RNG_test tools/practrand.sh --dry-run fast 16
zig build -Doptimize=ReleaseFast stream -- --engine fast --bytes 16 | /tmp/RNG_test stdin64
```

Broader documentation/roadmap validation command:

```text
$ zig build toolingcheck
toolingcheck ok
$ zig build roadmapcheck
roadmapcheck ok
```

## Result

S4-M357 is closed for the current bar: the external PractRand pipeline can now be
validated without PractRand installed, and custom binary paths are supported.
This is evidence/tooling hardening only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
