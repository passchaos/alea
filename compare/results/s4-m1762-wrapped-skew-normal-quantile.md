# S4-M1762 Wrapped Skew-Normal CDF/Quantile Image Fast Path

Date: 2026-11-20

## Gap

The wrapped skew-normal quantile was the slowest row in the throughput
harness: 0.085M quantiles/s and 0.647M CDF/s at a 1GiB-equivalent run
(262144 evaluations). Each CDF evaluation summed the `2*pi` images by
evaluating both the moving point and the fixed endpoint term per image, and the
quantile recomputed those endpoint terms on every Newton iteration. For the
thin skew-normal lower tail the safeguarded Newton also kept bisecting long
after the probability error had reached the f64 CDF noise floor.

## Change

`src/distributions.zig` now:

- adds `WrappedSkewNormalCdfCache`, which stores the per-image endpoint terms
  for the branch that contains the root and computes them lazily on first use
  (a quantile call only evaluates one branch);
- skips images where the evaluation point and the endpoint are both deeper than
  `|z| >= 9` in the same tail. Those per-image differences are zero at f64
  resolution (the skipped tail mass is below `1e-18`), so the result is
  bit-identical;
- fuses the CDF and density image loops for the quantile so the `z` values and
  the image walk are shared;
- stops the safeguarded Newton when the correction `|F(x) - p| / f(x)` is below
  the `1e-12` x tolerance, which is the same accuracy contract the previous
  bracket-width test enforced but avoids bisecting through the CDF noise floor;
- starts from the skew-normal quantile (wrapped into `(-pi, pi]`) for
  `sigma <= 2`, with the wrapped-normal probit start kept for `alpha == 0`.

The public CDF also uses the saturated-tail image skip.

## Measurements

Same host, `ReleaseFast -Dcpu=native`, `bench -- 1073741824 "wrapped skew"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea wrapped skew-normal quantile` | 0.085M quantiles/s | 0.254M quantiles/s | 2.99x |
| `alea wrapped skew-normal cdf` | 0.647M cdf/s | 1.326M cdf/s | 2.05x |

Both checksums are unchanged (`281729.930` quantiles, `95786.203` CDF),
confirming the same output values. At the 16MiB harness size the quantile row
moves 0.087M -> 0.260M quantiles/s and the CDF row 0.713M -> 1.411M cdf/s.

## Validation

- `zig build test --summary all`: 29/29 steps, 994/994 tests, including the
  wrapped skew-normal CDF/quantile round-trip, `alpha = 0` wrapped-normal
  equivalence, vector, checked, and parameter tests.
- `zig build distcheck`: `distcheck ok` (sampling gates unchanged).
- `zig build statcheck`: `statcheck ok`.
- The optimization is stream-preserving: CDF and quantile checksums are
  identical before and after, so no reproducibility-matrix mapping change is
  needed.

## Next Bar

Refresh validate-all/long-run evidence and continue with the remaining
vector-directional and quantile watch rows (Hoyt, StudentT, von Mises, wrapped
normal).
