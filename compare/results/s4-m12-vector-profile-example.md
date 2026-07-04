# S4-M12 Vector Profile Adoption Example

Date: 2026-07-04

Purpose: improve the adopted S4-M5 throughput-first vector profile surface by
adding an executable example that shows the explicit opt-in boundary between
exact/default vector normal/exponential APIs and accepted table/approx-log
profiles.

## Change

Added `examples/vector_profiles.zig` and build step:

```sh
zig build run-vector-profiles
```

The example:

- uses exact/default `fillVectorStandardNormalFrom` and
  `fillVectorStandardExponentialFrom`;
- uses `fillVectorStandardNormalTableF32From`,
  `fillVectorStandardExponentialTableF32From`, and
  `fillVectorStandardExponentialApproxLogF32From`;
- prints first vectors and small means to make the different output mappings
  visible;
- states that `Table` and `ApproxLog` names are explicit opt-ins trading exact
  ziggurat output mapping for throughput-first vector profiles.

## Validation

Command:

```sh
zig build run-vector-profiles
```

Result: passed and printed exact/default, table, and approx-log vector rows plus
the opt-in caveat.

`docs/core-guide.md` and `docs/api-reference.md` now list the new build step.

## S4-M12 Decision

S4-M12 is closed for the current adoption/documentation bar: accepted vector
profile users now have a runnable example in addition to API docs, validation
reports, and roadmap policy notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
