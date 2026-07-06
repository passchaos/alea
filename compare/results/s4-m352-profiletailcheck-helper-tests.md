# S4-M352 Profiletailcheck Helper Tests

## Gap

`profilecheck-tail` is the accepted vector-profile tail gate. Before S4-M352,
`zig build profilecheck-tail` only ran executable tail audits; helper logic for
accepted profile vector-type mapping, probability tolerance clamping, and
floating-point threshold predicates had no focused unit tests wired into the
build step.

## Change

`tools/profiletailcheck.zig` now includes focused tests for:

- accepted profile vector type selection (`f32x8` versus `f64x4` lane counts);
- probability lower/upper bound clamping to `[0, 1]`;
- `floatInClosedRange` finite inclusive lower/upper boundaries;
- low/high rejection paths;
- NaN rejection.

`build.zig` now creates `alea-profiletailcheck-tests` and makes
`zig build profilecheck-tail` run those tests before the `alea-profiletailcheck`
executable tail audit.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that profilecheck-tail runs helper tests.

## Validation

Focused validation command:

```text
$ zig build profilecheck-tail
profiletailcheck ok
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

S4-M352 is closed for the current bar: accepted vector-profile tail checking now
has a focused helper-test layer that runs before the executable checks. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
