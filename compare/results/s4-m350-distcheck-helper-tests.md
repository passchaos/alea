# S4-M350 Distcheck Helper Tests

## Gap

`distcheck` is the parameter-grid distribution gate used by `zig build validate`
and by WASI report chaining. Before S4-M350, `zig build distcheck` and
`zig build distcheck-libc` only ran executable distribution audits; helper
floating-point threshold predicates had no focused unit tests wired into those
build steps.

## Change

`tools/distcheck.zig` now includes focused tests for `floatInClosedRange`:

- finite inclusive lower/upper boundaries;
- interior accepted value;
- low/high rejection paths;
- NaN rejection.

`build.zig` now creates `alea-distcheck-tests` and `alea-distcheck-libc-tests`,
and makes `zig build distcheck` / `zig build distcheck-libc` run those tests
before their executable distribution audits. `zig build validate` now depends on
the full distcheck steps, not only the checker executables, so native validation
also includes the helper tests.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that distcheck and distcheck-libc run helper tests.

## Validation

Focused validation commands:

```text
$ zig build distcheck
$ zig build distcheck-libc
distcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
examplecheck ok
toolingcheck ok
readmecheck ok
roadmapcheck ok
```

## Result

S4-M350 is closed for the current bar: distribution-grid checking now has a
focused helper-test layer that runs before both default and libc-linked
executable audits. This is evidence/tooling hardening only; it does not resolve
S4-M11 and is not whole-goal completion evidence.
