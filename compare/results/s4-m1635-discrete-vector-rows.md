# S4-M1635 Discrete Vector Benchmark Rows

Date: 2026-11-15

Added the remaining discrete vector benchmark rows with the scalar parameters
and generalized `benchVectorDistribution` to accept integer-lane vectors:

| Row | Vectors/s | Samples/s |
| --- | --- | --- |
| `alea vector binomial f64x4` (40, 0.25) | 5.3 M | 21 M |
| `alea vector poisson f64x4` (20) | 21.2 M | 85 M |
| `alea vector geometric f64x4` (0.25) | 177.1 M | 708 M |
| `alea vector hypergeometric f64x4` (100, 30, 10) | 18.3 M | 73 M |
| `alea vector negative-binomial f64x4` (5, 0.4) | 33.1 M | 132 M |
| `alea vector zipf f64x4` (10, 1.5) | 15.6 M | 62 M |
| `alea vector zeta f64x4` (3) | 32.7 M | 131 M |

The discrete vector samplers are per-lane scalar draws by design, so the rows
expose coverage rather than a packed-versus-per-lane gap. The scalar
`alea binomial` row's 889 M samples/s is a comptime-specialized facade
artifact: a probe that cached the dyadic decomposition in `Binomial` measured
no change in the runtime vector row (5.6 -> 5.9 M, noise) and was reverted.

## Validation

- `zig build bench -Doptimize=ReleaseFast -- 16777216 "vector ..."` builds and
  runs all seven rows.
- Benchmark-only: no library code, stream, or public API changed.

## Changed Files

- `bench/throughput.zig`: seven rows, the integer-lane checksum branch in
  `benchVectorDistribution`, and the `V4U` alias.
