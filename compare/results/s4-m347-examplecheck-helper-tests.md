# S4-M347 Examplecheck Helper Tests

## Gap

`examplecheck` verifies that runnable examples are documented, individually
runnable, wired into aggregate `zig build examples`, and retain key adoption
output tokens. Before S4-M347, `zig build examplecheck` only ran the executable
catalog audit; helper assumptions for known-example lookup and per-example
metadata shape had no focused unit tests wired into the build step.

## Change

`tools/examplecheck.zig` now includes focused tests for:

- `knownExample`, with representative positive examples and a missing negative
  case;
- every catalog entry's source path, focused `zig build run-*` command shape,
  and `examples_step.dependOn(...)` aggregate dependency-token shape.

`build.zig` now creates `alea-examplecheck-tests` and makes `zig build
examplecheck` run those tests before the `alea-examplecheck` executable audit.
`zig build doccheck` now depends on the full `examplecheck` step, not only the
checker executable, so documentation validation also includes the helper tests.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that examplecheck runs helper tests.

## Validation

Focused validation command:

```text
$ zig build examplecheck
examplecheck ok
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

S4-M347 is closed for the current bar: examples-catalog checking now has a
focused helper-test layer that runs before the executable audit. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
