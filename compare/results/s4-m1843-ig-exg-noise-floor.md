# S4-M1843 Stop the Inverse-Gaussian and Ex-Gaussian Quantiles at the CDF Noise Floor

Date: 2026-11-20

## Gap

Both the inverse-Gaussian and ex-Gaussian quantiles iterate until the
bracket collapses or the step stagnates. Their CDFs use the
Abramowitz-Stegun `normCdf`, which carries an absolute error of about
1.5e-7 — far above the `1e-12` x tolerance the loops aim for — so the last
two or three Halley steps only chase approximation noise. The measured
iteration means were 5.74 (IG) and 6.52 (ex-Gaussian), and even the centre
of the distribution needed 5.5-5.9 iterations.

## Change

Both loops now stop when `|f − p| <= d·1e-12·max(1, |x|) + floor` with
`floor = min(1e-8, p·1e-5)`. The `1e-8` is fifteen times below the CDF's
own A&S error, so the floor cannot move the true quantile; the `p·1e-5` cap
keeps the deep tails from stopping at a large relative error.

## Measurements

- Direct sweeps: inverse-Gaussian 183.9 ns → 89.8 ns per call (about −51%);
  ex-Gaussian 168.4 ns → 105.5 ns (about −37%).
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `inverse-gaussian quantile` 4.852, 5.080, 5.136, 5.090 M/s before and
  10.514, 10.494, 10.471, 10.420 M/s after (median 5.085M to 10.483M, about
  +106%); `ex-gaussian quantile` 5.918, 5.904, 5.923, 5.876 M/s before and
  9.080, 9.439, 9.379, 9.421 M/s after (median 5.914M to 9.400M, about
  +59%). All eight pairs favor the change.

## Accuracy

Self-consistent round trips (`CDF(quantile(p))` against the same CDF) move
from 2.8e-13 (IG) and 1.4e-10 (ex-Gaussian) worst to at most 7.8e-6 and
2.3e-6 *relative* in the deep tail — absolute errors of at most 1e-11,
still 1000x inside the tests' 1e-5 tolerances and well below the CDF's own
1.5e-7 A&S error, which dominates the true quantile accuracy in any case.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The inverse-Gaussian quantile is now about 10.5M quantiles/s and the
ex-Gaussian about 9.4M/s. Keep the no-known-gaps and long-run evidence
current, and revisit the large-hypergeometric codegen gap.
