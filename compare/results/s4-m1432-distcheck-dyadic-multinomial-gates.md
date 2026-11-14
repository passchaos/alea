# S4-M1432 — Dyadic fill and multinomial marginal gates in distcheck

## Goal

Lock the recent packed-fill and multinomial-ordering changes into the
aggregate `distcheck` gates so accidental distribution drift fails both the
native check and the 10M long sweep.

## Change

- `checkDyadicChanceFills` fills 100,000 bools for each of ten packed
  probabilities (`0.25`, `0.375`, `0.5`, `0.0625`, `0.75`, `0.125`, `0.1875`,
  `0.3125`, `0.875`, `0.0078125`) and requires the observed fraction to stay
  within ±0.006 of the request. This covers the dedicated masks, the nibble
  kernels, and the small-dyadic ratio kernel.
- `checkVectorDistributions` now accumulates each multinomial category over
  its 5,000 draws and gates the marginal means at `100·p_i/6 ± 0.5`. The
  sampler draws the largest category first, so this is the gate that would
  catch an ordering bug that keeps the total correct.

## Evidence

- `zig build distcheck` prints `distcheck ok`.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)` with both gates active.
- `zig build test --summary all` passes 903/903.

## Validation

- `zig build test` passes 903/903, including `apicheck` and `roadmapcheck`.
- `zig build distcheck` and `zig build statcheck` pass.
- The 10M long run passes.

## Next bar

Broader platform runners, longer external statistical sweeps when PractRand
is available, or newly discovered core gaps.
