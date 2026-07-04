# S4-M15 Examples Validation Gate

Date: 2026-07-04

Purpose: prevent runnable adoption examples from drifting after S4-M12 through
S4-M14 added examples for accepted vector, LogNormal, and NativeF32 profiles.

## Change

Added build step:

```sh
zig build examples
```

The step runs:

- `examples/basic.zig`
- `examples/vector_profiles.zig`
- `examples/lognormal_profiles.zig`
- `examples/native_f32_profiles.zig`

`zig build validate` now depends on the `examples` step, so ordinary validation
compiles and runs all user-facing examples.

## Validation

Command:

```sh
zig build examples
```

Result: passed. All examples printed deterministic demo output and completed.

## S4-M15 Decision

S4-M15 is closed for the current examples-drift bar: user-facing examples are now
part of local validation instead of being only manually runnable.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
