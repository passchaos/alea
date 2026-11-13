# S4-M1329 — Matrix Fisher O(3) example and long-run coverage

## Goal

Round out the S4-M1327/S4-M1328 O(3) matrix Fisher work with runnable-example
coverage and a 1,000,000-sample long-run gate.

## Changes

### Directional example

`examples/directional.zig` now constructs `MatrixFisherO3(f64)` with `F = 2I`,
prints the deterministic SO(3) mixture weight, and estimates the
positive-determinant rate over 5,000 samples. Example output:

```
matrix Fisher O(3) SO weight: 0.068, positive-det rate: 0.065
```

`tools/examplecheck.zig` catalogs `MatrixFisherO3(f64)` and `soWeightValue`.

### Long-run check

`checkLongRun` adds a 1,000,000-sample O(3) matrix Fisher gate: the
positive-determinant frequency must match `soWeightValue()` within `±0.005`.
The command

```
zig build -Doptimize=ReleaseFast distcheck -- --long 1000000
```

prints `distlongcheck ok (1000000 samples)`.

## Validation

- `zig build run-directional` prints the O(3) weight and determinant rate
  above.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 1000000` passes.
- `zig build test --summary all` passes 884/884 tests with all documentation
  gates.
- `compare/results/core-rand-coverage.md` S4-M1329 row added.

## Next bar

Further vector compaction/squeeze optimizations, broader platform runners, or
newly discovered core gaps.
