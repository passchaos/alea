# S4-M345 Toolingcheck Helper Tests

## Gap

`toolingcheck` verifies the build-step and checked-tool catalog, plus dependency
shape for doccheck, validate, validate-all, wasi-report, surfacecheck,
runtimecheck, and roadmapcheck. Before S4-M345, `zig build toolingcheck` only ran
the executable audit; its helper lookup functions for known build steps and tools
had no focused unit tests wired into the build step.

## Change

`tools/toolingcheck.zig` now includes focused tests for:

- `knownBuildStep`, including `toolingcheck`, `validate`, `validate-local`,
  `validate-all`, and a negative missing-step case;
- `knownTool`, including `tools/toolingcheck.zig`, `tools/roadmapcheck.zig`, and
  a negative missing-tool case.

`build.zig` now creates `alea-toolingcheck-tests` and makes `zig build
toolingcheck` run those tests before the `alea-toolingcheck` executable audit.
`zig build doccheck` now depends on the full `toolingcheck` step, not only the
checker executable, so documentation validation also includes the helper tests.

`tools/toolingcheck.zig` also guards this new dependency shape, and
`docs/tooling.md` documents that toolingcheck runs helper tests.

## Validation

Focused validation command:

```text
$ zig build toolingcheck
toolingcheck ok
```

Broader documentation/roadmap validation command:

```text
$ zig build doccheck
examplecheck ok
readmecheck ok
apicheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M345 is closed for the current bar: tooling catalog checking now has a focused
helper-test layer that runs before the executable audit. This is evidence/tooling
hardening only; it does not resolve S4-M11 and is not whole-goal completion
evidence.
