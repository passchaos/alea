# S4-M1370 — Scalar tail for the vector Kent Wood proposal

## Goal

Eliminate the repeated full-vector redraws in the vector Kent Wood proposal
by finishing the last pending lanes with the scalar Wood sampler.

## Implementation

- Extracted `kentWoodScalarFrom`, the scalar Wood proposal loop (including the
  `proposal_lambda == 0` uniform-sphere case), shared by `kentSampleWFrom`
  and the vector tail.
- `vectorWoodW` now counts pending lanes after each vector round; when at most
  four remain it fills them with `kentWoodScalarFrom` and exits, mirroring the
  scalar tails already used by the Watson, Bingham, vMF, and Kent main
  acceptance loops.
- The proposal law and the I₀-weighted acceptance are unchanged; only the
  redraw strategy and therefore the RNG consumption order change.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea vector kent f64x4 3d` | 4.1M vectors/s | 4.8M vectors/s | +15% |
| `alea kent 3d` | 26.9M samples/s | 26.6M samples/s | within noise |

The vector checksum changes to `7297499978426234569` and is stable; the
scalar checksum remains `9761654497349534419`.

## Validation

- All 10 scalar/vector Kent tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further vector rejection-loop tuning, or newly discovered core gaps.
