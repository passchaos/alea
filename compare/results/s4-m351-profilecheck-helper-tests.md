# S4-M351 Profilecheck Helper Tests

## Gap

`profilecheck` is the accepted vector-profile distribution gate used by
`zig build validate` and by WASI report chaining. Before S4-M351,
`zig build profilecheck` only ran executable vector-profile audits; helper logic
for accepted profile vector-type mapping and floating-point threshold predicates
had no focused unit tests wired into the build step.

## Change

`tools/profilecheck.zig` now includes focused tests for:

- accepted profile vector type selection (`f32x8` versus `f64x4` lane counts);
- `floatInClosedRange` finite inclusive lower/upper boundaries;
- interior accepted value;
- low/high rejection paths;
- NaN rejection.

`build.zig` now creates `alea-profilecheck-tests` and makes
`zig build profilecheck` run those tests before the `alea-profilecheck`
executable vector-profile audit. `zig build validate` now depends on the full
profilecheck step, not only the checker executable, so native validation also
includes the helper tests.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that profilecheck runs helper tests.

## Validation

Focused validation command:

```text
$ zig build profilecheck
profilecheck ok
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

S4-M351 is closed for the current bar: accepted vector-profile checking now has a
focused helper-test layer that runs before the executable checks. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not whole-goal
completion evidence.
