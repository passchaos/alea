# S4-M1424 — Nibble-expanded fills for the remaining k/16 probabilities

## Goal

Give every `k/16` probability a table-expanded fill. S4-M1420 routed the
remaining dyadic probabilities to the packed power-of-two ratio kernel, which
still stores one bool byte per trial; the dedicated nibble kernel writes two
bool bytes per lookup.

## Change

- `ExpandNibblesBelow(limit)` generates a 256-entry table at comptime that
  maps each byte's two 4-bit fields (low field first) to two bool bytes, with
  a field succeeding when it is below `limit`.
- `fillChanceNibblesFrom` consumes 16 fields per engine word and writes two
  bool bytes per table lookup, mirroring the existing 1/16 kernel.
- `fillChanceFrom` dispatches `k/16` for `k` in `{2, 3, 5, 7, 9, 10, 11, 13,
  14, 15}`. The dedicated kernels for 1/16, 1/4, 3/8, 1/2, and 3/4 stay first
  because their packed masks are faster.

## Results

Interleaved same-period A/B with two saved binaries (16 MiB, two rounds):

- `alea fillChance p=1/8`: 1784-1793M -> 2391-2653M samples/s (+34-48%),
  checksum `262835` -> `262447` because the field width changes from 3 to 4
  bits,
- `alea fillChance p=3/16`: 1743-1784M -> 2436-2546M samples/s (+40-43%),
  checksum unchanged (`394069`) because both kernels use the same 4-bit field
  stream,
- `alea fillChance p=5/16`: new row at 2427-2502M samples/s, previously served
  by the one-store-per-trial ratio kernel.

Existing rows keep their checksums and stay within noise: `p=0.25`
3451-3484M, `p=0.5` 3610-3746M, `p=3/8` 2523-2634M, `p=1/16` 2481-2772M,
`p=3/4` 3225-3373M. The true-fraction test now covers 0.125, 0.1875, 0.3125,
0.4375, 0.625, 0.875, and 0.9375 in addition to the earlier cases.

## Validation

- `zig build test --summary all` passes 903/903,
- `zig build distcheck` and `zig build statcheck` pass,
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.

## Next bar

Broader platform runners, packed `fillRatio` for small non-power-of-two
denominators, or newly discovered core gaps.
