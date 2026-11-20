# S4-M1783 Halley Steps for the Skew-Normal Quantiles

Date: 2026-11-20

## Gap

`skewNormalQuantile` and `wrappedSkewNormalQuantile` both ran safeguarded
Newton on their CDFs. Newton converged linearly from the normal/skew-normal
starting guesses: 8-9 iterations for the standardized skew-normal and 4.2
image-sum iterations for the wrapped variant, each paying a full CDF (and
density) evaluation. The wrapped row was the slowest model in the harness at
0.31-0.34M quantiles/s and the skew row sat at 0.97-0.99M.

## Change

Both quantiles now take Halley steps, `x - 2 f f' / (2 f'^2 - f f'')`, with the
same bracket safeguards as before: the bracket is updated before the step, a
candidate outside `[lo, hi]` falls back to bisection, and the existing
tolerance/`next == x` exits are unchanged.

- `skewNormalPdfPairZ` returns the density and its derivative in one pass,
  sharing `φ(z)`, `Φ(αz)`, and `φ(αz)`.
- `WrappedSkewNormalCdfCache.eval` accumulates the wrapped density derivative
  `Σ 2φ(z)(−zΦ(αz) + αφ(αz))/σ²` in the same image loop that already computes
  the CDF and density, so the extra term costs a few flops per image.

Average iterations measured over a 100k-point `p` sweep: skew-normal 8-9 ->
5.69, wrapped skew-normal 4.20 -> 3.27.

## Measurements

Same-host A/B with two separately built `bench/throughput.zig` binaries
(`ReleaseFast -Dcpu=native`, `-- 16777216`), alternating old/new four times:

| Row | Before (M/s) | After (M/s) |
| --- | --- | --- |
| `skew-normal quantile` | 0.968, 0.972, 0.986, 0.993 | 1.067, 1.078, 1.121, 1.129 |
| `wrapped skew-normal quantile` | 0.312, 0.316, 0.319, 0.332 | 0.355, 0.360, 0.364, 0.374 |

That is about +12% for the skew-normal quantile and +13% for the wrapped
quantile; every new run is above every old run, so the shift clears the host
noise floor. A same-process timing probe showed the wrapped call drop from
3177-3185 ns to 2527-2580 ns (about 1.23-1.26x).

The harness checksums are unchanged at the printed resolution (2174.360 and
4282.426); the quantile contracts are tolerance-based (1e-9 CDF round-trip,
1e-12 x tolerance), and the focused skew/wrapped tests plus distcheck gates
pass.

## Rejected / neutral experiments

- Tightening the wrapped density image skip from `|z| >= 9` to `|z| >= 6.5`
  measured neutral (0.363-0.373 vs 0.340-0.370) and was reverted.
- Replacing the skew-normal starting guess with the cheap wrapped-normal
  quantile reached 6.28 Newton/Halley iterations and measured within noise of
  the skew-normal guess; the closer guess was kept.
- A hand-written 4-block word-major ChaCha12 core (no shuffles) tied Zig
  std's 16-lane implementation at about 2860 MiB/s generated keystream in
  interleaved A/B runs, so it was not landed. The remaining `chacha12
  fill-only` gap to Rust `StdRng` is the deliberate hidden-key prefix (6.25%
  of each 512-byte refill) plus a ~4% core-rate difference; closing it would
  need both a faster core and a versioned buffer-size change.

## Validation

- `zig build test --summary all`: 29/29 steps, 995/995 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck`: 26/26 steps, 19/19 tests.

## Next Bar

Keep the no-known-gaps comparison current and continue the Alea-only slow
rows (wrapped skew-normal CDF, skew-normal CDF, von Mises CDF) with same-host
A/B evidence.
