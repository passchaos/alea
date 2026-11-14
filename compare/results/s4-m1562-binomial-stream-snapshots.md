# S4-M1562 Binomial Dispatch-Region Stream Snapshots

Date: 2026-11-15

## Gap

The reproducibility matrix versions the binomial sampler's dispatch regions
(per-trial, packed dyadic, fair, small-mean inverse-CDF walk, HIN, huge fair
HIN, and the stable-tail HIN log ratio), but only the small-mean walk had an
explicit cross-type parity test. A future change to one region's draw order
could slip through the moments and empirical gates without an exact-stream
failure.

## Change

- Added `binomial method streams have stable snapshots` with one eight-draw
  snapshot per region, each reseeded independently from `ScalarPrng`:
  - `(20, 0.2)` per-trial threshold,
  - `(1000, 0.012)` one-uniform inverse-CDF walk,
  - `(10_000, 0.01)` HIN rejection,
  - `(1000, 0.5)` word-popcount fair path,
  - `(1_000_000, 0.5)` huge fair HIN dispatch,
  - `(1e18, 2e-17)` stable-tail HIN log ratio.
- The expected values are the current versioned streams; any deliberate
  stream change must update this test and the reproducibility matrix together.
- No production code, stream, or benchmark changed; the milestone is
  test-only.

## Validation

- `zig build test -Dtest-filter=binomial` passes 37/37.
- `zig build test distcheck --summary all` passes 958/958 tests (native
  `alea-tests` 937/937), including the existing walk parity and moments
  tests.
- `compare/results/reproducibility-matrix.md` points the binomial dispatch
  streams at this snapshot evidence.

The aggregate `validate-all` refresh is tracked as the following milestone.
