# S4-M1572 Noncentral-Family Extreme-Tail Round-Trips

Date: 2026-11-15

## Gap

The noncentral chi-squared/F/chi diagnostics were tested with
`p ∈ {1e-6, 0.3, 0.7, 1−1e-6}`. A probe of the exact Poisson-mixture paths
down to `p = 1e-12` showed relative round-trip errors of about `1e-15`, and
the huge-lambda Patnaik fallback showed about `2.5e-4` at `p = 1e-12`, but no
test pinned either behavior.

## Change

- Added `noncentral family extreme-tail round-trips`:
  - exact mixture paths (`noncentralChiSquared`, `noncentralF`,
    `noncentralChi` at `(3, 4)` / `(5, 10, 4)`) round-trip within `1e-9`
    relative at `p ∈ {1e-12, 1e-8, 1 − 1e-8}`,
  - the huge-lambda Patnaik fallback (`λ = 3e5`) round-trips within `1e-3`
    relative at `p ∈ {1e-8, 0.5, 1 − 1e-8}`, matching its documented
    two-moment approximation status.
- Test-only, no production code, stream, or benchmark changed.

## Validation

- `zig build test -Dtest-filter=oncentral` passes 61/61.
- `zig build test distcheck --summary all` passes 960/960 tests (native
  `alea-tests` 939/939).
- Probe values: exact paths `~1e-15` relative error at `p = 1e-12`; Patnaik
  `2.5e-4` at `p = 1e-12` and `1e-9` at `p = 0.5`.
