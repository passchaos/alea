# S4-M1872 Thin-Row No-Known-Gaps Refresh (Current Binary)

Date: 2026-11-21

The S4-M1853 no-known-gaps table predates the S4-M1854..M1871 work, and
the only row whose implementation changed is `alphanumeric` (S4-M1856).
This refresh re-measures the thin comparable rows on the current binary
(`2a6f2891`) against the local Rust harness, interleaved in the same
window (`-- 16777216`), so the ratios are directly comparable.

| Workload | Rust | Alea | Ratio |
| --- | --- | --- | --- |
| alphanumeric | 1024.9, 825.8, 1103.1M | 1484.4, 1408.3, 1326.4M | about 1.37x |
| standard-normal | 988.9, 766.2, 1005.5M | 893.3, 1125.3, 1068.7M | about 1.08x |
| normal-inverse-gaussian | 359.3, 364.7, 359.6, 361.6M | 376.4, 379.1, 381.9M | about 1.05x |
| poisson (prebuilt) | 109.4, 111.2M | 129.6, 130.7M | about 1.18x |
| inverse-gaussian (prebuilt) | 585.4, 584.1M | 651.2M | about 1.11x |

Notes:

- `alphanumeric` moved from 1.02x at S4-M1853 to about 1.37x, consistent
  with the S4-M1856 packed fill (+44% on the Alea side); every Alea run
  in this window is above every Rust run.
- `standard-normal`, `normal-inverse-gaussian`, `poisson`, and
  `inverse-gaussian` are unchanged since S4-M1853 and remain at or above
  parity; the inverse-Gaussian row had one load-spike outlier (448.2M)
  and is reported from the clean pair.
- The rest of the S4-M1853 table is unaffected: the sampling
  implementations for those workloads did not change, and the S4-M1854..
  M1871 work is CDF/quantile, geometry, charset, or model additions (the
  vector von Mises stream has its own 400M-lane audit and 1e9 lane gate).

## Validation

The rows were measured with the S4-M1853 harness commands and the same
16MiB budget; no library code changed in this milestone.

## Next Bar

The large-hypergeometric codegen gap remains the only sub-parity
comparable workload; the 24-hour wall-clock soak and a fresh 128GiB
PractRand pass (once PractRand is installed) are the next statistical
rungs.
