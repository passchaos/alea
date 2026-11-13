# S4-M1346 — SIMD Kent scalar-tail completion

## Goal

Finish the remaining SIMD directional rejection loops with the same
scalar-tail completion used by Watson and Bingham, and probe the equivalent
change for SIMD von Mises-Fisher.

## Implementation

- Extracted the scalar Kent marginal draw into
  `inline fn kentSampleWFrom(...)`: Wood proposal plus the I₀-weighted
  acceptance test with the Exp(1) race.
- `kentPointFrom` now calls the shared helper, so the scalar sampler and the
  SIMD tail use one implementation.
- `vectorKentPointFrom` counts the pending lanes after each vector marginal
  round; when `active_count ≤ 4` it fills the remaining lanes with
  `kentSampleWFrom` and exits the loop. The common angle/assembly code still
  handles every lane, so the change only affects RNG consumption order.

## Benchmarks (ReleaseFast, `-Dcpu=native`, 16,777,216 samples)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea vector kent f64x4 3d` | 3.9M vectors/s | 4.1M vectors/s | +5% |
| `alea kent 3d` | 17.3M samples/s | 17.4M samples/s | unchanged |

Probed and rejected: the same `active_count ≤ 4` scalar tail for
`vectorVmfPointFrom` measured 10.0-10.3M vectors/s against a 10.0-10.1M
baseline (neutral), so the vMF kernel was left unchanged. The scalar Kent
checksum is unchanged (`8180223920645759677`); the vector Kent checksum changes
(`14944598552313217847`) because the tail consumes randomness in a different
order, and the moment/parity tests remain green.

The helper must be `inline fn`: as a plain `fn`, scalar Kent dropped to about
16.3M samples/s; forcing inlining restores 17.4M and keeps the vector tail at
4.1M.

## Validation

- `zig test src/root.zig --test-filter "Kent"` passes all 10 scalar/vector Kent
  tests, including the `β = 0` VectorKent/vMF parity and f32x8 paths.
- `zig build distcheck` passes; `zig build test` passes 897/897.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
narrow-vector compaction for the remaining lanes, or newly discovered core
gaps.
