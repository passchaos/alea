# S4-M1768 1e7 Long-Run Refresh and Wrapped Skew-Normal Quantile Skip

Date: 2026-11-20

## Long-run refresh

`zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
`distlongcheck ok (10000000 samples)` (about 66 seconds). The run exercises the
full long gate set after the S4-M1761..M1767 performance work, including the
continuous CDF means (beta, gamma, Student-t, FisherF, exponential, log-normal,
log-logistic, Nakagami, ex-Gaussian, inverse Gaussian, skew-normal, PERT, Rice,
Hoyt), the heavy-tail rates, the copula lower-tail rates, the scalar/vector
binned chi-square gates, and the discrete CDF gates.

## Wrapped skew-normal quantile image skip

The wrapped skew-normal quantile cache now skips images whose evaluation point
and endpoint are both beyond `|z| >= 6.5` (previously 9). The skipped per-image
difference is below `4e-11`, far inside the quantile's `1e-9` round-trip
contract, and the skipped images are exactly the ones that would take the slow
Owen T adaptive-Simpson path. The public CDF keeps the tighter 9-sigma
threshold. Same-host 4.19M-call rows: wrapped skew-normal quantile
0.272M -> 0.286M quantiles/s with an unchanged checksum (`4509979.616`).

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000`:
  `distlongcheck ok (10000000 samples)`.
- `zig build statcheck`: `statcheck ok`.
- `zig build validate-all` evidence remains `s4-m1767-validate-all-refresh.md`;
  this run only changed a quantile-internal threshold and the docs.

## Next Bar

Refresh the 1e9 long-run evidence and continue with the remaining
Owen-T-limited quantile rows.
