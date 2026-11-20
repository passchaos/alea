# S4-M1862 Vector Von Mises Long-Run Gate

Date: 2026-11-20

## Gap

S4-M1860 changed the `VectorVonMises(f64x4)` proposal stream (the
range-reduced cos polynomial), but the long-run suite gated
`VectorVonMisesFisher`, `VectorWatson`, and `VectorBingham` without a
matching `VectorVonMises` lane moment. A versioned stream change should
carry its own long-run statistical gate.

## Change

`checkLongRun` now includes a `VectorVonMises(@Vector(4, f64))` lane
moment: with `mu = 0.4` and `kappa = 5`, the gate checks
`E[cos(X - mu)] = I1(5)/I0(5) = 0.8933831370440853` over `samples / 4`
vectors (four lanes each), using the same `longMeanTolerance(0.25,
samples, 0.003)` band as the vMF lane gate.

## Validation

- `zig build distcheck`: `distcheck ok`.
- `alea-distcheck --long 4000000`: `distlongcheck ok (4000000 samples)`
  with the new gate active.
- `zig build test --summary all`: 29/29 steps, 996/996 tests.

The 1e9 background run started before this gate existed, so its evidence
covers the same sampling code without the new lane check; the 4M run above
exercises the gate on the current binary.

## High-Volume Stream Audit

A dedicated 400M-lane audit of the S4-M1860 `VectorVonMises(@Vector(4,
f64))` stream (`mu = 0.4`, `kappa = 5`, 100M vectors, about 13.5 s of CPU)
gives:

- `mean cos(X - mu) = 0.89339177` against `I1/I0 = 0.89338314`
  (+0.38 SE);
- `mean sin(X - mu) = -2.79e-6` against 0 (-0.08 SE);
- a 36-bin chi-square over the full circle of 26.4 with 35 degrees of
  freedom (mean 35, sd 8.4), worst bin -2.48 SE.

The versioned cos-polynomial stream is therefore statistically
indistinguishable from the von Mises law at this volume.

## Next Bar

The 1e9 background run remains the next statistical bar; the
large-hypergeometric codegen gap remains the only sub-parity comparable
workload.
