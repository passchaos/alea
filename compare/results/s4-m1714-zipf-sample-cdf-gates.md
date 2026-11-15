# S4-M1714 Zipf Sample CDF Gates

Date: 2026-11-16

## Change

The long-run discrete block sampled `Zipf(40, 1.5)` (the
rejection-inversion path) and gated the `Zipf(10, 1.5)` fill CDF, but the
S4-M1711 `Zipf(10, 1.5)` sample CDF path had no statistical gate. Added a
`Zipf(10, 1.5)` sample gate at `2`, `4`, and `8` over the long-run sample
count. Tooling-only; no library code changed.

## Validation

- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` passes all
  long gates and prints `distlongcheck ok (10000000 samples)`.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 974/974
  tests (native 951/951).

## Changed Files

- `tools/distcheck.zig`: the `Zipf(10, 1.5)` sample sampler and three gates.
