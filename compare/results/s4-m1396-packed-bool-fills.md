# S4-M1396 — Packed scalar bool fills

## Goal

Replace the per-element bool-fill loops with SWAR bit packing: expand a byte of
eight packed bits into eight bool bytes with one table lookup and one 8-byte
store, so `Rng.fill(bool)`, `fillChance`, and `fillBernoulli` stop paying a
per-trial shift/compare/store.

## Implementation

- A comptime `expand_bits_8` table maps each byte to a `u64` whose eight bytes
  are the corresponding 0/1 bools.
- `storeBoolBits` writes the low `take` bits of a word as bool bytes: eight
  bytes per table lookup via `@bitCast` into a `[8]u8`, with a scalar tail for
  the final partial chunk. The destination `[]bool` is cast to `[]u8` (bool is
  one byte in Zig).
- `fillBoolsFrom` (the p = 1/2 path used by `Rng.fill(bool)` and
  `fillChance(0.5)`) keeps the historical most-significant-bit-first trial
  order by reversing the word with `@bitReverse` before expansion.
- `fillChanceQuarterFrom` (p = 1/4) builds the success mask at the even bit
  positions (`~bits & ~(bits >> 1) & 0x5555…`), compacts those bits to the low
  half with the standard even-bit gather, and expands eight at a time. The
  field order matches the previous least-significant-field-first loop, so the
  emitted bools are identical.
- `fillBernoulli`/`fillChance` already route through these kernels; no API
  change.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-period A/B with the change stashed:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea fillChance p=0.25` | 1996.2M samples/s | 3506.5M samples/s | +76% |
| `alea fillChance p=0.5` | 2039.7M samples/s | 3813.0M samples/s | +87% |
| `alea fillBernoulli p=0.25` | 1953.3M samples/s | 3478.8M samples/s | +78% |
| `alea fill bool facade` | 1912.9M samples/s | 3798.6M samples/s | +99% |

All four checksums are unchanged (`523602`, `1048457`, `524551`, `1049372`),
so the emitted bool sequences are bit-identical to the previous kernels.

## Validation

- `zig build test` passes 899/899, including the MSB-first bool-order test in
  `rng.zig` and all Bernoulli/chance fill tests.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/rng.zig` is clean.

## Next bar

Broader platform runners, packed fills for other dyadic ratios, or newly
discovered core gaps.
