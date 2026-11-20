# S4-M1807 1e7 Long-Run Refresh After the Quantile Optimization Wave

Date: 2026-11-20

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)` after the S4-M1783..M1806 wave.

The gates include the continuous CDF means
(`log-normal(1)=0.500164`, `skew-normal(0)=0.250156`, `rice(1)=0.396158`,
`hoyt(1)=0.663174`, `ex-gaussian(2)=0.460348`,
`inverse-gaussian(1)=0.627489`, `beta(0.3)=0.579888`, `gamma(3)=0.450438`,
`student-t(0)=0.499955`, `fisher-f(1)=0.534954`, `pert(0.5)=0.500061`), the
heavy-tail rates, the copula joint lower-tail rates, the discrete CDF gates
(`hypergeometric huge`, `negative-binomial mixture`, `beta huge`), and the
long-run binned chi-square gates.

No library code changed in this milestone. A 1e9 run is launched separately
for the deeper long-run evidence.

## Validation

- `distcheck -- --long 10000000`: `distlongcheck ok (10000000 samples)`.

## Next Bar

Keep the no-known-gaps comparison and the 1e9 long-run evidence current.
