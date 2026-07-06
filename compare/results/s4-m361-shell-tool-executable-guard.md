# S4-M361 Shell Tool Executable-Bit Guard

## Gap

`zig build practrand-dry-run` invokes `tools/practrand.sh` directly. If a future
change dropped the executable bit from a checked-in shell tool, the tooling
catalog could still pass while script-backed build steps failed at runtime.

## Change

`tools/toolingcheck.zig` now:

- identifies checked-in shell tools by `.sh` extension;
- checks executable access for every cataloged shell tool;
- includes focused tests for shell-tool detection.

`docs/tooling.md` now documents that toolingcheck also keeps shell tools
executable.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Permission evidence:

```text
$ ls -l tools/practrand.sh
-rwxrwxr-x ... tools/practrand.sh
```

## Result

S4-M361 is closed for the current bar: checked-in shell tools used by build steps
are now guarded for executable permissions. This is evidence/tooling hardening
only; it does not resolve S4-M11 and is not whole-goal completion evidence.
