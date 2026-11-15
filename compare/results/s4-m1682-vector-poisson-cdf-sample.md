# S4-M1682 Vector Poisson CDF Sample Path

Date: 2026-11-16

## Change

S4-M1677 gave `VectorPoisson.fill`/`fillFrom` a hoisted-CDF kernel for
`lambda < 12` but left `sample`/`sampleFrom` on the per-lane product method.
The single-vector path now builds the same small Poisson CDF table per call
(the table is deterministic and consumes no randomness) and uses the same
branchless vector search plus exact product fallback for the truncated tail.
`sample` delegates to `sampleFrom`, so every `lambda < 12` vector Poisson path
now uses the CDF stream and `fill` matches repeated `sampleFrom` again. A new
fill-vs-loop test pins that contract.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native` runs:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea vector poisson small f64x4` (lambda=4, throughput harness) | 14.1 M vectors/s | 22.8 M vectors/s | +62% |
| `vectorbench fillVectorPoisson small u64x4` | 133.8 M lanes/s | 137.2 M lanes/s | unchanged/noise |
| `vectorbench fillVectorPoisson small u64x4 direct` | 130.4 M lanes/s | 136.7 M lanes/s | unchanged/noise |
| `alea poisson small` (scalar) | 54.8 M samples/s | 55.7 M samples/s | unchanged |

The sample-row checksum changes (`8388258.000` -> `8385890.000`) because the
per-vector stream is versioned. The scalar sampler is unchanged.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native 950/950), including the new product-Poisson fill-vs-loop
  stream test and the `VectorPoisson(lambda=4)` CDF gate.
- `zig build distcheck --summary all`: 5/5 steps and 2/2 tests.

## Changed Files

- `src/distributions.zig`: `VectorPoisson.sample`/`sampleFrom` CDF path and
  the product fill-vs-loop test.
- `compare/results/reproducibility-matrix.md`: updates the versioned stream
  note so all `lambda < 12` vector Poisson paths share the CDF stream.
- `compare/results/performance-triage.md`: records the adoption.
