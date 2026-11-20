# S4-M1847 Skip the Rice and Hoyt Quantile Bracket Verification

Date: 2026-11-20

## Gap

Both the Rice and Hoyt quantiles verified their starting upper bracket with
a CDF evaluation on every call, and doubled it for targets above the first
guess: the Rice bracket started at `max(sigma, nu) + sigma` and the Hoyt at
`sqrt(omega)`, so high probabilities paid one to four extra CDF
evaluations before the Newton loop even began.

Guaranteed bounds exist and are cheap to write down:

- Rice: `nu + 40·sigma` leaves an upper tail below 7.5e-11 across
  `nu ∈ [0, 100]`, `sigma ∈ [0.5, 10]`;
- Hoyt: `40·sqrt(omega)` leaves an upper tail below 2.5e-13 across
  `q ∈ {0.01, 0.1, 0.5, 1}` and `omega ∈ {0.5, 1, 5}`.

Both main paths only handle `p <= 1 − 1e-6`, so the bracket cannot fail.

## Change

The Rice bracket is `nu + 40·sigma` and the Hoyt bracket is
`40·sqrt(omega)`; the verification loops are removed.

## Measurements

- Direct sweeps: Rice 179.2 ns → 141.7 ns per call (about −21%); Hoyt
  174.3 ns → 142.1 ns (about −19%), both with identical checksums.
- Same-host A/B with two separately built `bench/throughput.zig` binaries
  (`ReleaseFast -Dcpu=native`, `-- 16777216`), four alternating pairs:
  `rice quantile` 6.048, 5.681, 5.087, 5.387 M/s before and 6.495, 6.511,
  6.714, 6.351 M/s after (median 5.534M to 6.503M, about +18%);
  `hoyt quantile` 5.790, 5.330, 5.352, 5.265 M/s before and 6.399, 6.696,
  6.572, 6.544 M/s after (median 5.341M to 6.558M, about +23%). All eight
  pairs favor the change.

## Accuracy

The Rice round-trip audit over `nu ∈ {0, 0.5, 1, 5, 20, 100}`,
`sigma ∈ {0.5, 1, 2, 10}`, and eight probabilities gives 1.43e-10 worst
(the old bracket path measured 4.78e-10). The Hoyt audit is unchanged at
its pre-existing `q = 0.01` series-convergence limit, which both the old and
new brackets hit identically.

## Validation

- `zig build test --summary all`: 29/29 steps, 996/996 tests.
- `zig build distcheck`: `distcheck ok`.
- `zig build statcheck`: `statcheck ok`.
- `zig build doccheck` (included in the test run): 19/19 tests.

## Next Bar

The Rice quantile is now about 6.5M quantiles/s and the Hoyt about 6.6M/s.
Keep the no-known-gaps and long-run evidence current; the
large-hypergeometric codegen gap (0.86-0.87x) remains the only sub-parity
comparable workload.
