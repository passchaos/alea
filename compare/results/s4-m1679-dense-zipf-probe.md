# S4-M1679 Dense Zipf Probe (Rejected)

Date: 2026-11-16

## Probe

After the dense zeta and hoisted Poisson fill wins, tested whether the same
hybrid shape helps `VectorZipf`: one full-lane inverse-CDF attempt with vector
math (`base = pt*(1-s)+s`, reciprocal square for `q = -2`), a vector
`log`/`exp` acceptance test (`u2 <= exp(-s*log(x/inv_b))`), and scalar
continuation for rejected lanes. Added the candidate row and a local scalar
continuation to `bench/vector.zig`.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
"Zipf"` (ScalarPrng, n=10, s=1.5):

| Row | Throughput |
| --- | --- |
| `alea distributions.fillVectorZipf f64x4` (facade) | 71.6 M lanes/s |
| `... fillVectorZipf f64x4 direct` | 60.1 M lanes/s |
| `alea distributions.VectorZipf.fill f64x4` | 70.4 M lanes/s |
| `alea candidate fillVectorZipf dense f64x4` | 67.4 M lanes/s |

The candidate is about +12% over the direct row but 4-6% below the facade and
reusable-sampler rows, so it is not a durable real-harness win. The vector
`log`/`exp` acceptance cost offsets the SIMD inverse-CDF gain; replacing the
exact log/exp with approximations would change the acceptance probability and
break exactness.

## Decision

Rejected. `VectorZipf` keeps the per-lane scalar rejection-inversion stream.
The candidate row stays in `bench/vector.zig` as evidence.

## Validation

- `zig build -Doptimize=ReleaseFast -Dcpu=native vectorbench -- 16777216
  "Zipf"` builds and runs the baseline and candidate rows.

## Changed Files

- `bench/vector.zig`: the dense Zipf candidate row and local probe helpers.
- `compare/results/performance-triage.md`: records the rejection.
