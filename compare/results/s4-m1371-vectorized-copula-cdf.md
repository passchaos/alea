# S4-M1371 — Vectorized Student-t copula CDF

## Goal

Evaluate the three Student-t CDFs of a 3D copula draw in one SIMD pass
instead of three scalar calls, using Zig's vector `atan` and the existing
table-driven integer-degree recurrence.

## Implementation

- Added `studentTCdfVec4`, a four-lane version of the integer-degree
  recurrence: vector `atan`, `sqrt`, reciprocal, and recurrence arithmetic
  with the same `student_t_inv_ab_odd` / `student_t_inv_ab_even` tables, plus
  a vector sign select for negative `t`.
- `StaticStudentTCopula.sampleFrom` for `T == f64` and `dimension <= 4`
  builds a zero-padded four-lane `t` vector, guards on integer `df` in
  `[1, 64]` and finite lanes, calls the vector CDF, and clamps to the open
  interval; otherwise it falls back to the scalar path.
- The dynamic-vs-static copula test now compares to `1e-12` instead of exact
  equality, because the static vector path rounds differently from the
  dynamic scalar CDF.
- The vectorized path only changes the CDF evaluation order; the copula law
  and the underlying normal/chi-squared draws are unchanged.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

Same-host A/B, five runs each:

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea student-t copula 3d` | 16.9M samples/s | 44.0M samples/s | +160% |

The checksum changes to `18351266873679278732` (stable across runs) because
the CDF now rounds through the vector path.

## Validation

- All 34 copula tests pass, including the dynamic/static parity, parameter
  validation, and empirical-CDF gates.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
vectorized CDFs for other copulas, or newly discovered core gaps.
