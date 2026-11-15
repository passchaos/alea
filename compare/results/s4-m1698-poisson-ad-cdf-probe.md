# S4-M1698 Poisson Ahrens-Dieter CDF Probe (Rejected)

Date: 2026-11-16

## Probe

After the finite-support CDF wins, tested whether the `lambda >= 12`
Ahrens-Dieter vector fill benefits from the same shape: build a windowed
Poisson CDF table once per slice and draw each lane with one uniform plus a
per-lane binary search. Added a candidate row to `bench/vector.zig` for
`lambda = 20`.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
"lambda=20"` (ScalarPrng):

| Row | Throughput |
| --- | --- |
| `alea distributions.fillVectorPoissonAhrensDieter u64x4 lambda=20` (facade) | 111.7 M lanes/s |
| `... direct` | 129.5 M lanes/s |
| `alea distributions.VectorPoissonAhrensDieter.fill u64x4` | 111.5 M lanes/s |
| `alea candidate fillVectorPoisson AD cdf u64x4` | 129.7 M lanes/s |

The candidate matches the direct row (about +0.2%) and is only 16% above the
facade row, so it is not a durable win. The AD kernel's normal/exponential
draws and polynomial envelope cost about the same as the binary search over
the roughly 50-entry table, and the per-lane search branches add no headroom.

## Decision

Rejected. `VectorPoissonAhrensDieter` keeps the Ahrens-Dieter kernel and the
existing stream. The candidate row stays in `bench/vector.zig` as evidence.

## Validation

- `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
  "lambda=20"` builds and runs the baseline and candidate rows.

## Changed Files

- `bench/vector.zig`: the Poisson AD CDF candidate row and local probe.
- `compare/results/performance-triage.md`: records the rejection.
