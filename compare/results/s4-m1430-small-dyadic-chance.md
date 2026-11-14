# S4-M1430 — Small dyadic chance fills up to denominator 2^31

## Goal

Extend the dyadic `fillChance` coverage past denominators of 64. Small
probabilities such as p = 1/128 still used the per-element threshold loop
even though the packed power-of-two ratio kernel handles them.

## Change

- `chanceDyadicRatio` now accepts `m <= 31` (denominators up to 2^31) instead
  of `m <= 6`. The numerator still fits `u32`, and the packed ratio kernel
  extracts `64 / m` fields per word.
- `Bernoulli.fillDispatch` recovers the ratio from the threshold's trailing
  zeros (`@ctz`) instead of a six-step shift loop. A dyadic `k / 2^m` stores
  `k << (64 - m)`, so `m = 64 - @ctz(p_int)` and the same `m <= 31` bound
  applies in O(1).
- The true-fraction test now also covers p = 1/128 and p = 1/1024, and a
  `alea fillChance p=1/128` benchmark row was added.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, three rounds):

- `alea fillChance p=1/128`: 838-846M -> 1582-1726M samples/s (+87-104%),
  checksum `16550` -> `16238` because the stream changes from the per-element
  threshold loop to the packed ratio kernel,
- every other `fillChance` row keeps its checksum and stays within noise:
  `p=0.25` 3481-3514M, `p=0.5` 3681-3734M, `p=3/8` 2561-2628M, `p=1/16`
  2400-2743M, `p=3/4` 3231-3420M, `p=1/8` 2465-2596M, `p=3/16` 2397-2638M,
  `p=5/16` 2392-2808M.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, packed `fillRatio` for small non-power-of-two
denominators, or newly discovered core gaps.
