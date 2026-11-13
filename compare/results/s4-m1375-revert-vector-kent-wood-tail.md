# S4-M1375 — Revert the vector Kent Wood tail after a layout regression

## Goal

Remove the S4-M1370 vector Kent Wood scalar tail because it regressed the
core skew-normal sampler through code layout by far more than it gained on
the niche vector Kent row.

## Evidence

A fresh full-suite comparison against the S4-M1354 baseline showed
`alea skew-normal` down about 13%. A `git worktree` bisect at the relevant
commits, measured in the same session, isolated the cause:

| Commit | `alea skew-normal` | `alea skew-normal scalar direct` |
| --- | --- | --- |
| S4-M1366 (`d46db231`) | 572-578M | 670-672M |
| S4-M1369 (`3deea15d`) | 552-577M | 635-671M |
| S4-M1370 (`95c402e6`, vector Wood tail) | 496-505M | 561-569M |
| S4-M1371 (`2f638b5d`) | 500-505M | 559-566M |

The regression appears exactly at S4-M1370. Neither the skew-normal sampler
nor the ziggurat code changed; the added vector-tail code shifted the hot
loop's layout. The trade was +15% on `vector kent` (4.1M → 4.8M vectors/s)
versus about -13% on a ~575M samples/s core row.

## Revert

- Removed the `active_count <= 4` scalar tail from `vectorWoodW` and the
  `kentWoodScalarFrom` helper; `kentSampleWFrom` is back to its original
  inlined Wood loop.
- Measured after the revert: `alea skew-normal` 575-593M and scalar direct
  660-676M (restored), `alea kent 3d` 26.7-26.8M (preserved), and
  `alea vector kent f64x4 3d` back to 4.1M with its original checksum
  (`14944598552313217847`).

## Validation

- All 10 scalar/vector Kent tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
layout-safe vector rejection tuning, or newly discovered core gaps.
