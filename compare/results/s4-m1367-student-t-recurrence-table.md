# S4-M1367 — Table-driven Student-t recurrence denominators

## Goal

Remove the two divisions and the `B(a, 1/2)` recurrence update from every
step of the integer-degree Student-t CDF recurrence.

## Implementation

- Added comptime tables `student_t_inv_ab_odd` and `student_t_inv_ab_even`
  holding `1 / (a · B(a, 1/2))` for each recurrence step (32 entries each,
  generated from `B(a+1, 1/2) = B(a, 1/2) · a / (a + 1/2)`).
- `studentTCdfSmallInteger` now advances with
  `ib -= x_to_a · sin θ · inv_ab; x_to_a *= x; a += 1`, so each step is
  three multiplies with one table load instead of two divisions and a
  multiply.
- The base cases, `atan`, `sin θ`, symmetry, and the general incomplete-beta
  path are unchanged. The table introduces only last-bit rounding differences.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea student-t copula 3d` | 16.4M samples/s | 17.4M samples/s | +6% |

The checksum changes in the low bits
(`18351266873678738913` → `18351266873678599012`) and is stable.

## Validation

- All 22 `studentTCdf` tests pass, including the recurrence-vs-incomplete-beta
  grid at `1e-12`.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
vectorized `atan` for the copula CDFs, or newly discovered core gaps.
