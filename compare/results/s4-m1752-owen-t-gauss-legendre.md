# S4-M1752 Owen T Gauss-Legendre Fast Path

Date: 2026-11-16

## Change

`owenT` used adaptive Simpson for every call, and the skew-normal CDF/quantile
spent most of their time there. Added a fixed 24-point Gauss-Legendre
quadrature for `|h| <= 3` and `|a| <= 6`, keeping the adaptive Simpson
fallback outside that range and the `a = ±∞` closed form.

The rule was validated against the adaptive Simpson path over
`h = 0..3`, `a = 0.1..6`; the new test asserts agreement at `1e-12`.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"skew-normal"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea skew-normal cdf` | 0.501 M/s | 3.384 M/s | 6.8x |
| `alea skew-normal quantile` | 0.060 M/s | 1.432 M/s | 23.9x |

Checksums are unchanged (`1717.912`, `2174.360`).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 986/986
  tests (native `alea-tests` 963/963).
- The new `Owen T Gauss-Legendre matches adaptive Simpson` test covers
  `h = 0/0.1/0.5/1/2/3` and `a = 0.1/0.5/1/2/5/6`.
- Existing skew-normal CDF/quantile reference tests pass.
- Follow-up: S4-M1753 refreshes `validate-all`.
