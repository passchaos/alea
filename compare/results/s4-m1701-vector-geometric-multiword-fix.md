# S4-M1701 Vector Geometric Multi-Word Lane Fix

Date: 2026-11-16

## Bug

The first 1e9-sample run with the S4-M1680 dyadic probability gates failed
at `long vector geometric pmf chi-square p=0.0625` with a statistic of
`57,059,059` against the `29.45` bound.

`vectorGeometricDyadicFrom` draws one packed word per lane per round and
keeps drawing until every lane has found a success. Finished lanes still
draw words (the stream shape), but the accumulation did not exclude them:
`out += select(word_done, fields, per_word)` used only the current word's
status, so a finished lane kept adding fields from every later round.

The bias grows with the probability that a 64-bit word contains no success:

- `p = 1/16` (`m = 4`): `(15/16)^16 = 0.356` per lane per word. A 4M-lane
  audit measured `P(X = 1) = 0.0183` against `0.0625` and mean failures
  `24.3` against `15`.
- `p = 1/8` (`m = 3`): `(7/8)^21 = 0.061`, a smaller bias.
- `p = 1/4` (`m = 2`): `(3/4)^32 = 1e-4`, rarely visible.
- `p = 1/2` (`m = 1`): `2^-64`, effectively never.

The default 100k-sample distcheck does not run the long gates, so the bug
only surfaced in the 1e9 run.

## Fix

The accumulation is now gated on the lane's existing `done` flag:

```zig
const add = @select(u64, word_done, fields, @splat(per_word));
out += @select(u64, !done, add, @splat(0));
done = done | word_done;
```

Finished lanes still draw their words, so the stream shape is unchanged; only
the incorrect outputs change.

## Verification

- 4M-lane audit after the fix: `P(X = 1) = 0.06244` against `0.0625`, mean
  failures `15.03` against `15`; all eight pmf bins match the exact geometric.
- New unit test `vector geometric dyadic multi-word lanes stay exact`
  (100k lanes at `p = 0.0625`) asserts the rate and mean.
- `zig build test distcheck statcheck --summary all`: 39/39 steps and 970/970
  tests (native 950/950).
- Benchmark checksums change because the affected lanes now return the
  correct value: `alea vector geometric f64x4` `8396308.000` -> `8394545.000`
  and `alea vector geometric-failures f64x4` `6293501.000` -> `6292084.000`;
  throughput stays at about 296-300M vectors/s.

## Changed Files

- `src/distributions.zig`: the `vectorGeometricDyadicFrom` accumulation fix
  and the regression test.
- `compare/results/reproducibility-matrix.md`: records the versioned stream
  correction.
