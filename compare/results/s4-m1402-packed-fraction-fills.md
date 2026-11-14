# S4-M1402 — Packed bool fills for the 3/8 and 1/16 ratios

## Goal

Extend the packed scalar bool fills to `p = 3/8` and `p = 1/16`, which
previously fell back to the per-element threshold loop, and add benchmark rows
for both ratios.

## Implementation

- `expand_zero_nibbles` maps a byte holding two 4-bit fields to two bool bytes
  (low field first); `fillChanceSixteenthFrom` writes 16 fields per word with
  eight table lookups and eight 2-byte stores.
- `expand_three_fields` maps nine bits holding three 3-bit fields to three bool
  bytes; `fillChanceThreeEighthsFrom` writes 21 fields per word with seven
  lookups and seven 3-byte stores, plus a scalar tail for the final partial
  chunk.
- `fillChanceFrom` dispatches `p == 0.375` and `p == 0.0625` to the new
  kernels; other dyadic ratios keep the generic power-of-two field loop.
- New benchmark rows `alea fillChance p=3/8` and `alea fillChance p=1/16`, and
  a new test checks the true fraction for p = 0.25, 0.375, 0.5, and 0.0625 over
  100,000 bools.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-period A/B with the kernels stashed:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea fillChance p=3/8` | 1294-1303M samples/s | 2615-2631M samples/s | +102% |
| `alea fillChance p=1/16` | 1297-1310M samples/s | 2566-2597M samples/s | +98% |

The sampled laws are unchanged; the consumed stream differs, so the checksums
shift and are stable (`786642` → `786231` and `131246` → `131042`). The
existing `fillChance p=0.25` / `p=0.5` rows are unaffected.

## Validation

- The new dyadic fill probability test and all Bernoulli/chance fill tests
  pass.
- `zig build test` passes 901/901 (882 library tests plus 19 tool gates),
  including `apicheck` and `roadmapcheck`.
- `zig build distcheck` passes and `zig build statcheck` passes.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/rng.zig bench/throughput.zig` is clean.

## Next bar

Broader platform runners, packed fills for other dyadic ratios, or newly
discovered core gaps.
