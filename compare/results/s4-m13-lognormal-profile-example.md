# S4-M13 LogNormal Profile Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for LogNormal throughput/accuracy opt-in
profiles, complementing the S4-M12 vector normal/exponential profile example.

## Change

Added `examples/lognormal_profiles.zig` and build step:

```sh
zig build run-lognormal-profiles
```

The example compares:

- exact/default `fillLogNormalFrom(f32)`;
- exact `BufferedLogNormal(f32, 8)` with the explicit refill contract;
- `fillLogNormalNativeF32From`;
- `fillLogNormalExp2F32From`;
- `fillLogNormalNativeExp2F32From`;
- platform `LogNormalDlsymExp` and `LogNormalLibmvec` when available, otherwise
  a clear unavailable message.

It prints first samples and small means, then states that exact LogNormal should
be used for stable `@exp` output and named Native/Exp2/libc profiles should be
used only when their output-mapping/platform contracts are acceptable.

## Validation

Command:

```sh
zig build run-lognormal-profiles
```

Result: passed. On this non-libc-linked default example build, the platform
libc-backed profiles report unavailable as expected.

`docs/core-guide.md` and `docs/api-reference.md` list the new build step.

## S4-M13 Decision

S4-M13 is closed for the current adoption/documentation bar: LogNormal opt-in
users now have runnable guidance in addition to API docs, transform notes,
benchmarks, and validation evidence.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
