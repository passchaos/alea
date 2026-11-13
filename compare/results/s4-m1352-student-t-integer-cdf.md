# S4-M1352 — Exact integer-degree Student-t CDF recurrence

## Goal

Remove the incomplete-beta continued-fraction cost from `studentTCdf` for
small integer degrees of freedom, which dominates Student-t copula sampling
where the same `ν` is evaluated once per output coordinate.

## Implementation

- Added `studentTCdfSmallInteger`, a closed-form path for integer `ν` in
  `[1, 64]`. It starts from the exact `ν = 1` or `ν = 2` base case and applies
  the regularized incomplete-beta recurrence
  `I_x(a+1, 1/2) = I_x(a, 1/2) − x^a √(1−x) / (a B(a, 1/2))`,
  which advances two degrees of freedom per step.
- The recurrence carries `x^a` and `B(a, 1/2)` incrementally, so each step
  costs one multiply, one divide, and one subtract; `ν = 5` needs two steps.
- `studentTCdf` dispatches to the recurrence when `ν` is an integer in range
  and otherwise keeps the existing incomplete-beta path unchanged. The
  `ν > 1e6` normal approximation, endpoints, NaN handling, and negative-`t`
  symmetry are unchanged.
- The recurrence is exact for integer `ν`; only last-ulp differences from the
  continued fraction remain. No public API change.

## Accuracy check

A new unit test compares the recurrence against `betaIncomplete(ν/(ν+t²),
ν/2, 1/2)` for every integer `ν` in `[1, 64]` and
`t ∈ {-20, -10, -5, -2, -1, -0.5, -0.1, 0, 0.1, 0.5, 1, 2, 5, 10, 20}`:

```
max absolute difference < 1e-12
```

The existing known-value, symmetry, large-`ν`, and f32 tests also pass.

## Benchmark (ReleaseFast, `-Dcpu=native`, 16,777,216 bytes)

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea student-t copula 3d` | 4.3M samples/s | 16.3M samples/s | +279% |

The benchmark checksum changes from `18351266873691370517` to
`18351266873678738913` and is stable across three runs. Only the low bits
move: the normal and chi-squared draws are unchanged, and the copula uniforms
differ at roughly `1e-15` relative because the CDF is evaluated by a different
exact expression.

## Validation

- `zig build test` passes 899/899, including the new recurrence-vs-incomplete-
  beta accuracy test.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
further copula or vector-directional kernel optimization, or newly discovered
core gaps.
