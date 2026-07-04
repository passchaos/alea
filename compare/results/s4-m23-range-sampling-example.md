# S4-M23 Range And Uniform Sampling Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for integer ranges, strict float
intervals, duration ranges, bulk range fills, reusable `Uniform` samplers, vector
ranges, collapsed point masses, and checked range errors.

## Change

Added `examples/range_sampling.zig` and build step:

```sh
zig build run-range-sampling
```

The example demonstrates:

- `intRangeLessThan` and `intRangeAtMost` for half-open and inclusive integer
  ranges;
- `float`, `floatOpen`, `floatOpenClosed`, and `floatRange` endpoint semantics;
- `durationRangeAtMost` for `std.Io.Duration`;
- `fillRangeFrom` for integer and float slices;
- `fillOpenClosedFrom` for strict endpoint-sensitive float fills;
- reusable `Uniform(T).init` and `Uniform(T).initInclusive` diagnostics and
  fills;
- vector range/open/open-closed helpers and distribution `vectorUniformFrom`;
- valid collapsed point-mass float ranges and checked invalid range errors.

## Validation

Command:

```sh
zig build run-range-sampling
```

Result: passed and printed deterministic range/uniform outputs.

`zig build examples` includes this example, so `zig build validate` covers it
through the examples validation gate added in S4-M15.

## S4-M23 Decision

S4-M23 is closed for the current range/uniform adoption bar: range and endpoint
semantics users now have runnable guidance in addition to API docs, unit tests,
benchmarks, and reproducibility notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
