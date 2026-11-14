# S4-M1420 — Packed dyadic fills for 3/4 and other power-of-two ratios

## Goal

Extend the packed `fillChance` kernels beyond p = 1/4, 3/8, 1/2, and 1/16.
Previously p = 3/4, 1/8, 7/8, and every other dyadic probability fell back to
the per-element threshold loop that draws one engine word per bool.

## Change

- `fillChanceQuarterFrom` gains a comptime `inverted` flag. The normal form
  succeeds on 2-bit fields equal to zero (p = 1/4); the inverted form succeeds
  on fields not equal to zero (p = 3/4). Both share the even-bit gather and
  eight-at-a-time bool-byte expansion.
- A new `chanceDyadicRatio` decomposes any `p = k / 2^m` with `m <= 6` from
  the f64 bit pattern. Probabilities not covered by the dedicated kernels
  route to the existing `fillRatioPowerOfTwoFrom`, which packs `64 / m` trials
  per engine word.
- `fillRatioFrom` gains the matching 3/4 case so the integer-ratio API uses
  the same inverted kernel.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, three rounds):

- `alea fillChance p=3/4`: 839-850M -> 3236-3364M samples/s (+285%),
  checksum `1572614` -> `1573550`,
- `alea fillChance p=1/8`: 840-854M -> 1762-1821M samples/s (+110%),
  checksum `262469` -> `262835`.

Existing rows keep their checksums and stay within noise: `p=0.25`
3417-3476M, `p=0.5` 3684-3767M, `p=3/8` 2516-2552M, `p=1/16` 2464-2726M.
The checksum shifts are the expected stream-shape changes for the two newly
packed probabilities.

The true-fraction test now covers p = 0.25, 0.375, 0.5, 0.0625, 0.75, 0.125,
0.875, and 0.3125 over 100,000 samples each.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, a table-expanded kernel for 1/8-style ratios, or
newly discovered core gaps.
