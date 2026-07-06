# S4-M346 Apicheck Helper Tests

## Gap

`apicheck` verifies that public Alea symbols are covered by
`docs/api-reference.md`. Before S4-M346, `zig build apicheck` only ran the
executable coverage audit; helper logic for identifier-boundary matching,
nested generic-parent matching, and public symbol/type parsing had no focused
unit tests wired into the build step.

## Change

`tools/apicheck.zig` now includes focused tests for:

- `containsSymbol` identifier-boundary matching;
- `containsNestedSymbol` dotted and generic-parent documentation forms;
- `publicSymbolName` parsing for public functions, inline functions, constants,
  and private negative cases;
- `publicTypeName` parsing for public structs and generic type factories.

`build.zig` now creates `alea-apicheck-tests` and makes `zig build apicheck` run
those tests before the `alea-apicheck` executable audit. `zig build doccheck` now
depends on the full `apicheck` step, not only the checker executable, so
documentation validation also includes the helper tests.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that apicheck runs helper tests.

## Validation

Focused validation command:

```text
$ zig build apicheck
apicheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M346 is closed for the current bar: API-reference coverage checking now has a
focused helper-test layer that runs before the executable audit. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
