# S4-M1754 Marcum P1 Recurrence Fast Path

Date: 2026-11-16

## Change

`marcumP1` summed the Rice CDF series with one `gammaIncompleteP(k+1, y)`
call per term. For moderate `a` and `y`, the incomplete-gamma terms now follow
the recurrence

`P(k+2, y) = P(k+1, y) - y^(k+1)·e^(−y)/(k+1)!`

starting from `P(1, y) = 1 − e^(−y)`. The recurrence is used when
`a²/2 <= 12.5` and `y = b²/2 <= 12.5`; larger parameters keep the log-scaled
series. A new test compares the recurrence to the series over
`a = 0.1..5`, `b = 0.1..5` at `1e-12`.

## Measurements

Focused `zig build -Doptimize=ReleaseFast -Dcpu=native bench -- 16777216
"rice"`:

| Row | Before | After | Delta |
| --- | --- | --- | --- |
| `alea rice quantile` | 0.218 M/s | 2.330 M/s | 10.7x |
| `alea rice cdf` | new row | 63.463 M/s (15.8 ns/call) | new benchmark |

The quantile checksum is unchanged (`6230.417`).

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 987/987
  tests (native `alea-tests` 964/964).
- The new `marcumP1 recurrence matches the log-scaled series` test covers the
  fast-path range; existing Rice CDF/quantile reference tests pass.
- Follow-up: S4-M1755 refreshes `validate-all`.
