# S4-M1829 Reuse the Cached Owen Geometry in the Wrapped Quantile Start

Date: 2026-11-20

## Gap

`wrappedSkewNormalQuantileImpl` builds its `WrappedSkewNormalCdfCache` (and
its Owen T geometry table for the shape) up front, but the one Newton step
that sharpens the wrapped-normal start still called `skewNormalCdfZ`. That
generic path evaluates `owenT`, which rebuilds the 24-node Gauss-Legendre
geometry inline — 24 cosines, an atan, and 24 reciprocals — for every call,
even though the cache had just built the same geometry for the same shape.

## Change

The start step now dispatches through the cache's tables:
`skewNormalCdfZWithGlTable20` when `0 < |alpha| <= 2`,
`skewNormalCdfZWithGlTable` for `|alpha| <= 6`, and the generic path
otherwise. The start only needs a rough CDF, so the 20-point rule's
6e-13 error is irrelevant there; the Halley loop that follows is unchanged.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `wrapped skew-normal quantile` | 0.836, 0.874, 0.825 | 0.925, 0.899, 0.873 |

Every paired run favors the reuse; the median moves from 0.836M to 0.899M
(about +7.5%) with identical checksums (`4282.426`), confirming the start
lands at the same root.

## Accuracy

The S4-M1824 contract grid (`CDF(quantile(p))` over `sigma ∈ {0.2 … 9}`,
`alpha ∈ {−10 … 10}`, seven probabilities): worst round-trip error
5.49796e-11, identical to before this change.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The wrapped skew-normal quantile is now about 0.90M/s; the Halley solve
itself (about four evaluations at ~150 ns each) remains the cost. Keep the
no-known-gaps and long-run evidence current.
