# S4-M1606 README Distribution and Diagnostics Refresh

Date: 2026-11-15

## Change

The README's feature overview was missing several distributions and
diagnostics added during this session:

- distribution list: added `generalized Pareto` and `generalized extreme
  value` next to the inverse-Gaussian family;
- diagnostics list: added
  `generalizedParetoCdf` / `generalizedParetoQuantile`,
  `generalizedExtremeValueCdf` / `generalizedExtremeValueQuantile`,
  `vonMisesCdf` / `vonMisesQuantile`, and
  `wrappedCauchyCdf` / `wrappedCauchyQuantile`.

## Validation

- `zig build readmecheck doccheck --summary all` passes 26/26 steps and
  19/19 tests.
- Docs-only: no library code, sampling stream, public API, or benchmark
  changed.
