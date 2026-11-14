# S4-M1528 64-Bit Integer Search in Discrete Quantiles

Date: 2026-11-15

## Problem

`binomialQuantile`, `negativeBinomialQuantile`, and `poissonQuantile` used
`usize` for their integer search variables and overflow guards. On wasm32
(32-bit `usize`) this made the same diagnostics call behave differently from
64-bit native targets:

| call | native 64-bit | wasm32 before |
| --- | --- | --- |
| `poissonQuantile(0.5, 1e12)` | ~1e12 | NaN (`lambda > maxInt(usize)/4`) |
| `binomialQuantile(0.5, 1e12, 0.5)` | 5e11 | NaN (`n > maxInt(usize)`) |
| `negativeBinomialQuantile(0.5, 1, 1e-10)` | ~6.93e9 | inf (search capped at `2^32`) |

The WASI distcheck added in S4-M1527 exposed the Poisson case:
`poisson huge quantile cdf: nan not in [0.000001, 1.000000]`.

## Change

All three quantiles now use `u64` search variables and `u64` overflow
guards, so 32-bit and 64-bit targets agree up to the f64 exact-integer range
and beyond. The binomial guard is also strict (`n < 2^64`) so the
`@intFromFloat` conversion cannot overflow at the boundary. Values above
`2^64` still return NaN/inf as before; the f64 return type cannot represent
consecutive integers above `2^53`, which is inherent to the API.

This is a diagnostics correctness/portability fix; no RNG stream changes.

## Validation

- New unit test `discrete quantiles use a 64-bit integer search on 32-bit
  targets` checks the inversion invariants for all three distributions with
  parameters above `2^32`, and runs on both native and WASI through
  `validate-all`.
- `zig build test-wasi --summary all` passes 920/920.
- `zig build validate-all --summary all` passes 124/124 steps and 1867/1867
  tests, including the WASI distcheck that previously failed.
