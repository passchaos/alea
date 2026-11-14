# S4-M1426 — Dyadic threshold dispatch for Bernoulli bulk fills

## Goal

Cover every dyadic probability that `Rng.fillChance` packs, not just the six
values S4-M1422 listed explicitly. The reusable `Bernoulli` sampler stores
only the 64-bit threshold, so the dispatch previously compared it against a
fixed probability list; p = 5/16, 3/16, 7/16, and the other ratios still fell
back to the per-element loop.

## Change

`Bernoulli.fillDispatch` now recovers the probability from the threshold
itself. A dyadic `p = k / 2^m` with `m <= 6` stores
`p_int = k << (64 - m)`, so a comptime loop over `m = 1..6` shifts the
threshold down, checks that the low bits are zero, and delegates to
`Rng.fillChanceFrom` with the exact `k / 2^m` value. The zero and one point
masses keep their `@memset` paths, and non-dyadic probabilities keep the
per-element threshold loop.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, two rounds):

- `alea fillBernoulli p=5/16`: 841.7M -> 2534-2635M samples/s
  (+201-213%), checksum `655910` -> `654408` from the packed stream shape,
- `alea fillBernoulli p=0.25`, `p=3/4`, and `p=1/8` keep their checksums and
  throughput (3328-3379M, 3303-3381M, 2438-2513M).

The same dispatch now covers p = 3/16, 7/16, 9/16, and every other
denominator-up-to-64 dyadic ratio.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, packed `fillRatio` for small non-power-of-two
denominators, or newly discovered core gaps.
