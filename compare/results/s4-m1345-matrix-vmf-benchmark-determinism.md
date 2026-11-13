# S4-M1345 — Matrix vMF benchmark determinism

## Problem

`benchMatrixVonMisesFisher` created its stateful Gibbs sampler once, outside the
timing trial loop. Each trial therefore continued the Markov chain from the
previous trial's final state, so the per-trial checksums differed and the
reported checksum depended on which trial happened to be fastest. Two
consecutive runs produced different checksums
(`18105066877552417898` and `12233297820294880330`), making the fixed-seed
performance row non-reproducible.

## Fix

The sampler is now created inside each trial (with `defer deinit` per
iteration), so every trial starts from the same burn-in state and samples the
same chain. The benchmark still reports the best throughput; the checksum is
now identical across trials and runs:

```
alea matrix von mises-fisher 3x2: 0.4 M samples/s checksum=18105066877552417898
```

Six consecutive runs produced the same checksum. The rate is about 0.4M
samples/s; the previously recorded ~0.5M predates the S4-M1332 correction that
routes the 3×2 Gibbs conditional through the exact circular von Mises sampler
instead of the biased Wood S¹ path.

## Validation

- `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
  "matrix von mises-fisher"` runs with a stable checksum across six runs.
- `zig fmt --check bench/throughput.zig` is clean.
- `zig build test` passes 897/897; distcheck and the WASI report are unaffected
  because only the benchmark harness changed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further performance work (vector-directional squeeze/compaction), or newly
discovered core gaps.
