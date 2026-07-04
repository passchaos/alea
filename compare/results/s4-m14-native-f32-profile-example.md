# S4-M14 NativeF32 Profile Adoption Example

Date: 2026-07-04

Purpose: add runnable adoption guidance for native-f32 normal/exponential opt-in
profiles, complementing the vector table/approx-log and LogNormal profile
examples.

## Change

Added `examples/native_f32_profiles.zig` and build step:

```sh
zig build run-native-f32-profiles
```

The example compares exact/default f32 outputs with named `NativeF32` profiles:

- `fillStandardNormalFrom(f32)` vs `fillStandardNormalNativeF32From`;
- `fillNormalFrom(f32, mean, stddev)` vs `fillNormalNativeF32From`;
- `fillStandardExponentialFrom(f32)` vs `fillStandardExponentialNativeF32From`;
- `fillExponentialFrom(f32, rate)` vs `fillExponentialNativeF32From`;
- exact/default vector standard normal vs `fillVectorStandardNormalNativeF32From`.

It prints first samples and small means, then states that `NativeF32` names are
explicit opt-ins using f32-native ziggurat candidates and intentionally do not
match the exact/default f64-backed f32 output mapping.

## Validation

Command:

```sh
zig build run-native-f32-profiles
```

Result: passed and printed exact/default versus native-f32 scalar/vector rows and
the opt-in caveat.

`docs/core-guide.md` and `docs/api-reference.md` list the new build step.

## S4-M14 Decision

S4-M14 is closed for the current adoption/documentation bar: native-f32
normal/exponential opt-in users now have runnable guidance in addition to API
docs, benchmark notes, validation gates, and reproducibility notes.

This does not close S4-M11's exact/default dense-kernel or future-runner blocker,
and it does not close the long-term product objective.
