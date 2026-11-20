# S4-M1778 Facade-Aware f32 Standard Normal Fill

Date: 2026-11-20

## Gap

`fillStandardNormalFrom(f32)` routed every source through the vector8 chunk
path. That path issues fewer, wider engine draws and wins for monomorphized
direct sources, but the type-erased `Rng` facade pays the vtable cost per draw,
so the facade fill ran at about 377M samples/s while the direct-source rows
reached 650-695M.

## Change

`fillStandardNormalFrom` now uses the scalar per-element loop when the source is
the `Rng` facade (`comptime @TypeOf(source) == Rng`) and keeps the vector8
chunk path for direct sources. The two paths produce the same stream: the
`fillStandardNormal f32` benchmark checksum is unchanged.

The same split was tested for `fillStandardExponentialFrom(f32)` and rejected:
the facade row moved from 562.3M to 529.9M samples/s (the exponential vector
chunk path is already the better shape for the facade), so that fill keeps the
vector path unconditionally.

## Measurements

Same host, `ReleaseFast -Dcpu=native`,
`bench -- 16777216 "fillStandardNormal f32"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea fillStandardNormal f32` (facade) | 377.2M samples/s | 529.5-561.4M samples/s | about 1.4-1.5x |
| `alea fillStandardNormal f32 fast direct` | 680.6M | 655-695M | unchanged |
| `alea fillStandardNormal f32 scalar direct` | 659.5M | 647-687M | unchanged |

Checksum unchanged (`-540.108`).

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests (the f32 fill
  stream-shape tests pass).
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- No reproducibility-matrix mapping change is needed because the output stream
  is identical.

## Next Bar

Continue the remaining Alea-only slow rows and keep the no-known-gaps
comparison current.
