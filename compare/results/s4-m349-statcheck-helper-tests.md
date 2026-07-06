# S4-M349 Statcheck Helper Tests

## Gap

`statcheck` is the lightweight statistical smoke gate used by `zig build
validate` and by the roadmap Current Rule after engine, distribution, range, or
sampling-internal changes. Before S4-M349, `zig build statcheck` only ran the
executable smoke checks; helper closed-range predicates for integer and floating-point
thresholds had no focused unit tests wired into the build step.

## Change

`tools/statcheck.zig` now includes focused tests for:

- `intInClosedRange` inclusive integer lower/upper boundaries;
- `intInClosedRange` low/high rejection paths;
- `floatInClosedRange` inclusive finite lower/upper boundaries;
- `floatInClosedRange` low/high and NaN rejection paths.

`build.zig` now creates `alea-statcheck-tests` and makes `zig build statcheck`
run those tests before the `alea-statcheck` executable smoke checks. `zig build
validate` now depends on the full `statcheck` step, not only the checker
executable, so native validation also includes the helper tests.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that statcheck runs helper tests.

## Validation

Focused validation command:

```text
$ zig build statcheck
statcheck ok
```

Broader validation command:

```text
$ zig build doccheck
apicheck ok
examplecheck ok
readmecheck ok
roadmapcheck ok
toolingcheck ok
```

## Result

S4-M349 is closed for the current bar: statistical smoke checking now has a
focused helper-test layer that runs before the executable checks. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
