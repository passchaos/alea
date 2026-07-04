# S4-M20 Unit Geometry Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for unit geometry samplers: circle,
disc, sphere, ball, their fill APIs, reusable diagnostics, and vector-lane
helpers.

## Change

Added `examples/unit_geometry.zig` and build step:

```sh
zig build run-unit-geometry
```

The example demonstrates:

- scalar `unitCircleFrom`, `unitDiscFrom`, `unitSphereFrom`, and `unitBallFrom`;
- norm checks distinguishing unit surfaces from filled volumes;
- `fillUnitCircleFrom`, `fillUnitDiscFrom`, `fillUnitSphereFrom`, and
  `fillUnitBallFrom` for slices of fixed-size point arrays;
- reusable sampler diagnostics such as dimension, surface flag, coordinate
  variance, and radial mean;
- `vectorUnitCircleFrom` and `vectorUnitBallFrom` for vector-lane batches.

It prints deterministic points and a short decision guide: use circle/sphere for
surfaces, disc/ball for filled volumes, fill helpers for point slices, and vector
helpers for vector-lane batches.

## Validation

Command:

```sh
zig build run-unit-geometry
```

Result: passed and printed deterministic unit-geometry outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M20 Decision

S4-M20 is closed for the current unit-geometry adoption bar: unit geometry users
now have runnable guidance in addition to API docs, unit tests, benchmarks, and
parity notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
