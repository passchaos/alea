# S4-M1671 Scalar Small-Lambda Poisson Coverage Row

Date: 2026-11-16

## Change

The throughput harness had scalar Poisson rows at `lambda = 20` but no scalar
row at the small-`lambda` product-method range, while
`alea vector poisson small f64x4` uses `lambda = 4`. Added
`alea poisson small` (`lambda = 4`) by parameterizing `benchPoisson` through a
shared `benchPoissonLambda` helper. Benchmark-only; no library code changed.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench` runs:

| Row | 16 MiB | 128 MiB |
| --- | --- | --- |
| `alea poisson small` (`lambda = 4`, scalar) | 54.8 M samples/s | 54.2 M samples/s |
| `alea vector poisson small f64x4` | 14.1 M vectors/s (56.4 M lanes/s) | 14.5 M vectors/s (58.0 M lanes/s) |

The per-lane vector rate is at scalar parity (slightly above in the longer
run), so the remaining `VectorPoisson` small-`lambda` gap versus the
`lambda = 20` rows is the product-method draw cost, not vector-loop overhead.
This closes the open parity question recorded in `performance-triage.md`; the
previously rejected small-`lambda` inverse-CDF probe remains rejected.

## Validation

- `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 134217728
  "poisson small"` runs the bench tests and both rows.
- `zig build roadmapcheck doccheck apicheck readmecheck --summary all` passes.

## Changed Files

- `bench/throughput.zig`: `benchPoissonLambda` and the `alea poisson small`
  row.
- `compare/results/performance-triage.md`: records the parity evidence.
