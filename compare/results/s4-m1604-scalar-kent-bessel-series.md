# S4-M1604 Scalar Kent Bessel Series

Date: 2026-11-15

## Change

The vector Kent acceptance has used the 22-term `log I₀(a)` series since
S4-M1580, but the scalar Kent acceptance and the init-time marginal envelope
still called the branchy A&S helper (`@log(besselI0(a))`, ~`3.3e-8` log
error). The coefficients now live in a shared
`log_bessel_i0_series_coefficients` array, and `logBesselI0Kent` uses the
series for `a <= 1.5` and the A&S helper above. Both `kentSampleWFrom` and
`kentMarginalLog` use it, so the acceptance ratio and the `marginal_max_log`
envelope are computed with the same accurate form.

The truncation is below `2e-11` at `a = 1.5` and `2e-13` at `a = 1`.

## Accuracy

The scalar Kent acceptance log-ratio error improves from the A&S helper's
`~3.3e-8` to `1.2e-11`, matching the vector path (the vector series test
compares the shared coefficients against the A&S helper at `1e-7`).

## Performance

A/B in the same measurement period (the host was slower than the earlier
25M/6.5M period, so the absolute numbers are not comparable to older rows):

| Row | A&S helper | Series |
| --- | --- | --- |
| `alea kent 3d` | 21.3 M samples/s | 21.3 M samples/s |
| `alea vector kent f64x4 3d` | 5.4 M vectors/s | 5.7 M vectors/s |

Both are within the current machine noise; the series removes a libm `log`
per candidate but adds a 22-FMA chain, so the scalar path is neutral. The
vector path's checksum is unchanged (`5861445844103430486`).

## Stream

The scalar Kent benchmark checksum is unchanged
(`16320475167864103015`): with `~3e5` candidates in the 16MiB row, the chance
that a candidate lands within the `3e-8` threshold window is about `0.01`, so
no sampled value changed. The acceptance threshold is nevertheless more
accurate; `reproducibility-matrix.md` records the scalar Kent acceptance
precision alongside the S4-M1580 vector entry.

## Validation

- `zig build test -Dtest-filter=kent` passes.
- `zig build test distcheck --summary all` passes 971/971 tests (native
  950/950).
- No public API, sampler construction, or existing stream changed for the
  recorded parameters.
