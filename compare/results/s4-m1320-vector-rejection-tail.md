# S4-M1320 — Scalar-tail completion for SIMD Watson/Bingham rejection

## Goal

Improve the vector Watson and Bingham samplers, whose per-lane throughput was
below the scalar samplers because every rejection round redrew full vectors
even when only one or two lanes were still active.

## Changes

### Hybrid scalar tail

`vectorWatsonPointFrom` and `vectorBinghamPointFrom` now count the active
lanes after each vector rejection round. When at most two lanes remain, they
finish those lanes with the scalar sampler
(`watsonSampleWFrom` / `Bingham.sampleFrom`) and stop the vector loop. Accepted
lanes keep their vector-sampled values; only the residual lanes switch paths.

The same experiment was applied to `vectorVmfPointFrom` but not adopted: the
vMF Wood acceptance rate is high enough that the hybrid tail produced no
measurable change (9.9 → 10.0 M vectors/s, within noise), so the simpler
single-path implementation is kept.

## Evidence

Commands:
`zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "<filter>"`

| Row | Before | After | Change |
| --- | ---: | ---: | ---: |
| `alea vector watson f64x4 3d` | 2.8 M vectors/s | 3.7 M vectors/s | +32% |
| `alea vector watson` lanes/s | 11.2 M | 14.8 M | +32% |
| `alea vector bingham f64x4 3d` | 4.8 M vectors/s | 6.2 M vectors/s | +29% |
| `alea vector bingham` lanes/s | 19.2 M | 24.8 M | +29% |
| `alea vector von mises-fisher f64x4 3d` | 9.9 M vectors/s | 10.0 M vectors/s | unchanged (not adopted) |

The checksums changed for Watson/Bingham because the residual lanes consume
the RNG stream differently; the distributions are unchanged and the existing
moment tests still pass.

## Validation

- `zig test src/root.zig --test-filter "VectorWatson"` passes 4/4.
- `zig test src/root.zig --test-filter "VectorBingham"` passes 3/3.
- `zig build test --summary all` passes 876/876 tests.
- `zig build distcheck` passes.
- `zig build wasi-report` passes end-to-end and ends with `profilelongcheck ok`.
- `docs/core-guide.md` documents the residual-lane scalar fallback.
- `compare/results/core-rand-coverage.md` S4-M1320 row added.

## Next bar

Further vector compaction or squeeze optimizations, O(3) matrix Fisher
reflections, longer statistical validation runs, broader platform runners, or
newly discovered core gaps.
