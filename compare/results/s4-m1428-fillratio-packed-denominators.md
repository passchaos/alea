# S4-M1428 — Packed chance kernels for small power-of-two fillRatio denominators

## Goal

Route the integer-ratio fill through the same packed kernels as the
float-probability fill. `fillRatioFrom` only special-cased denominators 2 and
4, so `fillRatio(3, 8)`, `fillRatio(1, 8)`, and `fillRatio(5, 16)` used the
one-store-per-trial power-of-two ratio kernel even though `fillChance` had
faster packed kernels for those probabilities.

## Change

`fillRatioFrom` now sends every power-of-two denominator up to 16 to
`fillChanceFrom` with the exact f64 ratio. That reuses the dedicated 1/2,
1/4, 3/4, 3/8, and 1/16 masks and the nibble kernels for the remaining k/16
probabilities. Larger power-of-two denominators keep the generic packed ratio
kernel, and non-power-of-two denominators keep the per-element
`uintLessThanFrom` loop. The explicit denominator 2/4 special cases collapse
into the new branch.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, three rounds):

- `alea fillRatio 3/8`: 1864-1880M -> 2812-2845M samples/s (+51%), checksum
  unchanged (`785480`) because both kernels use the same 3-bit field stream,
- `alea fillRatio 1/8`: 1898-1910M -> 2564-2672M samples/s (+35-40%),
  checksum `261733` -> `262015` from the 3-bit-to-4-bit field change,
- `alea fillRatio 5/16`: 1820-1860M -> 2392-2562M samples/s (+31-38%),
  checksum unchanged (`654638`),
- `alea fillRatio 1/4` and `1/2` keep their checksums and throughput
  (3476-3506M and 3650-3778M).

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, packed `fillRatio` for small non-power-of-two
denominators, or newly discovered core gaps.
