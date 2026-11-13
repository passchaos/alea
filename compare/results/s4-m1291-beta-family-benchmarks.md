# S4-M1291 — Beta prime and beta-binomial benchmark rows

## Goal

Add benchmark coverage for the two Beta-family additions so their throughput is
tracked alongside the rest of the distribution matrix:

- `BetaPrime(3, 5)` scalar sampling.
- `BetaBinomial(20, 2, 3)` scalar sampling.

Local Rust `rand` / `rand_distr` has no matching beta-prime or beta-binomial
samplers, so these are Zig-only evidence rows rather than parity rows.

## Implementation

- `bench/throughput.zig` gains `benchBetaPrime` and `benchBetaBinomial`,
  following the existing 3-trial fixed-seed checksum harness.
- Both rows are invoked from the `advanced multivariate throughput` section
  with `bytes / 64` sample counts.
- README and `docs/core-guide.md` now mention beta prime and beta-binomial in
  the distribution lists, including their vector samplers.

## Evidence

Command: `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 <filter>`

| Row | M samples/s | Notes |
| --- | ---: | --- |
| `alea beta prime` | 77.7 | Beta draw + `B/(1−B)` transform |
| `alea beta binomial` | 45.5 | Beta draw + binomial draw |

## Validation

- `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216 "beta prime"`
  prints `alea beta prime: 77.7 M samples/s`.
- `... "beta binomial"` prints `alea beta binomial: 45.5 M samples/s`.
- `zig build test` passes 836/836 tests with all documentation gates.
- `compare/results/core-rand-coverage.md` S4-M1291 row added.

## Notes

- Both rows use the scalar samplers; the vector wrappers are lane-wise scalar
  loops and are not separately benchmarked.
- Absolute throughput remains host/compiler dependent; the fixed seeds and
  checksums make reruns comparable on the same host.

## Next bar

Matrix von Mises-Fisher, Kent distribution, vector/SIMD copula/Bingham sampling,
longer statistical validation runs, or newly discovered core gaps against local
Rust `rand` / `rand_distr` evidence.
