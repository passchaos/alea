# S4-M1654 Fair Geometric clz Path

Date: 2026-11-15

## Change

`geometricFailuresFrom(0.5)` used the exponential kernel
(`floor(E / -log(1-p))`) at 693-702 M samples/s, while `standardGeometric`
already counted leading zeros of a uniform word at ~1.7 G samples/s. Added a
`p == 0.5` branch to `geometricFailuresFrom` that counts `@clz` zeros of fresh
words (adding 64 and redrawing only when a word is all zeros), so
`geometric(0.5)`, `geometricFailures(0.5)`, and their reusable samplers share
the clz kernel.

## Measurements (same-period A/B)

| Row | Exponential path | clz path | Change |
| --- | --- | --- | --- |
| `alea geometric fair f64` (0.5) | 693-702 M | 1375.8-1396.9 M | +96-101% |
| `alea geometric failures f64` (0.25) | 754.4-762.5 M | 754.4-762.5 M | unchanged |
| `alea standard-geometric f64` (0.5) | 1220.9-1844.5 M | 1220.9-1844.5 M | unchanged |

The fair-row checksum changes `523782` -> `524286` (clz stream instead of the
exponential draw) and is versioned in `reproducibility-matrix.md`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 973/973
  tests (native `alea-tests` 950/950).

## Changed Files

- `src/distributions.zig`: the `p == 0.5` branch in `geometricFailuresFrom`.
- `bench/throughput.zig`: the `alea geometric fair` row and bench function.
- `compare/results/performance-triage.md`: records the adoption.
- `compare/results/reproducibility-matrix.md`: versions the stream.
