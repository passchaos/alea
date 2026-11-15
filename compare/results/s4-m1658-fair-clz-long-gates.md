# S4-M1658 Fair clz Long-Run Gates

Date: 2026-11-15

## New Gates

Added two long-run mean gates for the S4-M1654/S4-M1656 clz streams:

- `long geometric fair mean`: `geometric(0.5)` trials vs the exact mean `2`,
  with `longMeanTolerance(2.0, samples, 0.001)` (6-SE `2.7e-4` at 1e9);
- `long negative-binomial fair mean`: `negativeBinomial(5, 0.5)` failures vs
  the exact mean `5`, with `longMeanTolerance(10.0, samples, 0.002)`
  (6-SE `6.3e-4` at 1e9).

## Results

- `alea-distcheck --long 10000000` passes (`distlongcheck ok (10000000
  samples)`).
- `alea-distcheck --long 1000000000` prints `distlongcheck ok (1000000000
  samples)` with the two new gates and the existing discrete/continuous/tail/
  copula/binned gates passing. The discrete CDF values shift slightly from
  S4-M1644 (`binomial(4)=0.237513`, `negative-binomial(3)=0.656249`,
  `geometric(2)=0.639988`) because `geometric(0.5)`/`negativeBinomial(·,0.5)`
  now use the clz streams; the gates still pass. The continuous/tail/copula
  values reproduce S4-M1608/S4-M1615 (`gamma(3)=0.450579`, normal tail
  `0.002698`, student-t tail `0.030104`, Gaussian copula `0.001875`).

## Validation

- `zig build test distcheck --summary all`: 971/971 (native 950/950); the
  default mode compiles the `checkLongRun` path containing the new gates.

## Changed Files

- `tools/distcheck.zig`: the two fair clz mean gates.
- Roadmap/audit evidence only; no library code, stream, or benchmark changed.
