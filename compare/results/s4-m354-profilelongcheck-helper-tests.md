# S4-M354 Profilelongcheck Helper Tests

## Gap

`profilecheck-long` is the accepted vector-profile long-sweep gate. Before
S4-M354, `zig build profilecheck-long` only ran executable long-sweep audits;
helper logic for accepted profile vector-type mapping, probability tolerance
clamping, and floating-point threshold predicates had no focused unit tests wired
into the build step.

## Change

`tools/profilelongcheck.zig` now includes focused tests for:

- accepted profile vector type selection (`f32x8` versus `f64x4` lane counts);
- probability lower/upper bound clamping to `[0, 1]`;
- `floatInClosedRange` finite inclusive lower/upper boundaries;
- low/high rejection paths;
- NaN rejection.

`build.zig` now creates `alea-profilelongcheck-tests` and makes
`zig build profilecheck-long` run those tests before the `alea-profilelongcheck`
executable long-sweep audit.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that profilecheck-long runs helper tests.

## Validation

Focused validation command:

```text
$ zig build profilecheck-long
profilelongcheck ok
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

S4-M354 is closed for the current bar: accepted vector-profile long-sweep
checking now has a focused helper-test layer that runs before the executable
checks. This is evidence/tooling hardening only; it does not resolve S4-M11 and
is not whole-goal completion evidence.
