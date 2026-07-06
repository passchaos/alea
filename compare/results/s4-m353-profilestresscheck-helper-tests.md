# S4-M353 Profilestresscheck Helper Tests

## Gap

`profilecheck-stress` is the accepted vector-profile multi-seed stress gate.
Before S4-M353, `zig build profilecheck-stress` only ran executable stress
audits; helper logic for accepted profile vector-type mapping, probability
tolerance clamping, and floating-point threshold predicates had no focused unit
tests wired into the build step.

During the audit, the exponential aggregate loop also showed duplicate CDF/tail
count accumulation lines. Removing the duplicate avoids double-counting aggregate
CDF/tail observations and keeps the stress checker's aggregate gates meaningful.

## Change

`tools/profilestresscheck.zig` now includes focused tests for:

- accepted profile vector type selection (`f32x8` versus `f64x4` lane counts);
- probability lower/upper bound clamping to `[0, 1]`;
- `floatInClosedRange` finite inclusive lower/upper boundaries;
- low/high rejection paths;
- NaN rejection.

`build.zig` now creates `alea-profilestresscheck-tests` and makes
`zig build profilecheck-stress` run those tests before the
`alea-profilestresscheck` executable stress audit.

`tools/toolingcheck.zig` guards this new dependency shape, and `docs/tooling.md`
documents that profilecheck-stress runs helper tests.

## Validation

Focused validation command:

```text
$ zig build profilecheck-stress
profilestresscheck ok
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

S4-M353 is closed for the current bar: accepted vector-profile stress checking
now has a focused helper-test layer that runs before the executable checks, and
aggregate exponential CDF/tail counts are no longer duplicated. This is
evidence/tooling hardening only; it does not resolve S4-M11 and is not
whole-goal completion evidence.
