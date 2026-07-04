# S4-M7 Accepted Vector Profile Tail Check

Date: 2026-07-04

Purpose: extend accepted vector-profile validation beyond the S4-M6 deterministic
1Mi-lane mean/variance/CDF smoke checks with a longer, tail-focused run on the
local Linux target and the WASI runtime target.

## Tool Added

`tools/profiletailcheck.zig` samples each accepted throughput-first vector
profile for 8,388,608 lanes and checks tail probabilities:

- table normal profiles: two-sided `|x| >= 2.5`, `3.0`, `3.5`, and `4.0`, plus
  positive/negative tail balance and max absolute support near the documented
  table truncation around `4.01`;
- table exponential profiles: upper tails `x >= 4`, `6`, `8`, and `10`, plus max
  support near the documented table truncation around `10.397`;
- f32 approximate-log exponential profile: upper tails `x >= 4`, `6`, `8`, and
  `10`, plus max output smoke without the table-truncation cap.

The build step is `zig build -Doptimize=ReleaseFast profilecheck-tail`. The WASI
runner step is `zig build -Doptimize=ReleaseFast wasi-profiletailcheck`, and
`wasi-report` now depends on it.

## Native Linux Result

Command:

```sh
zig build -Doptimize=ReleaseFast profilecheck-tail
```

Result: passed, `profiletailcheck ok`.

Representative rows:

| Profile | Lanes | Tail evidence |
| --- | ---: | --- |
| `VectorStandardNormalTableF32` | 8,388,608 | max_abs `4.00877237`; `|x|>=2.5` `0.01246583`, `|x|>=3.0` `0.00270092`, `|x|>=3.5` `0.00048745`, `|x|>=4.0` `0.00012612`; positive/negative tails balanced within gates. |
| `VectorStandardNormalTableF64` | 8,388,608 | max_abs `4.00877259`; `|x|>=2.5` `0.01239479`, `|x|>=3.0` `0.00267076`, `|x|>=3.5` `0.00048494`, `|x|>=4.0` `0.00012279`; positive/negative tails balanced within gates. |
| `VectorStandardExponentialTableF32` | 8,388,608 | max `10.39720726`; `x>=4` `0.01823187`, `x>=6` `0.00248730`, `x>=8` `0.00030375`, `x>=10` `0.00005925`. |
| `VectorStandardExponentialTableF64` | 8,388,608 | max `10.39720771`; `x>=4` `0.01834893`, `x>=6` `0.00247633`, `x>=8` `0.00030220`, `x>=10` `0.00006247`. |
| `VectorStandardExponentialApproxLogF32` | 8,388,608 | max `17.32868004`; `x>=4` `0.01825690`, `x>=6` `0.00249147`, `x>=8` `0.00033379`, `x>=10` `0.00004554`. |

## WASI Runtime Result

Command:

```sh
zig build -Doptimize=ReleaseFast wasi-profiletailcheck
```

Result: passed through Node WASI. Because the WASI tail step depends on
`wasi-profilecheck`, the run also emitted `repro`, `statcheck ok`, `distcheck
ok`, `profilecheck ok`, then the same `profiletailcheck ok` rows.

The WASI tail rows matched the native deterministic rows listed above, giving a
second-target tail-focused execution check for the accepted approximation
profiles.

## S4-M7 Decision

S4-M7 is closed for the current bar: accepted vector approximation profiles now
have 8Mi-lane tail-focused gates on both native Linux and WASI, in addition to
S4-M6 1Mi-lane moment/CDF gates, snapshots, reproducibility documentation, and
real-harness throughput evidence.

This does not close the long-term objective. The next bar should move beyond
smoke/tail gates toward stress testing and platform breadth: longer multi-seed
runs, additional non-WASI executed targets, or a newly successful exact/default-
compatible dense SIMD kernel.
