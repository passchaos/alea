# S4-M9 Accepted Vector Profile Long Stress Check

Date: 2026-07-04

Purpose: extend accepted vector-profile validation beyond S4-M8's 2Mi-lane
multi-seed stress by running a materially longer deterministic sweep on native
Linux and WASI.

## Tool Added

`tools/profilelongcheck.zig` samples each accepted throughput-first vector
profile across 8 deterministic seeds with 1,048,576 lanes per seed (8,388,608
lanes per profile total). It checks:

- per-seed mean and variance windows;
- aggregate mean/variance windows;
- normal two-sided and one-sided tail gates at `|x| >= 2.5`, `3.0`, `3.5`, and
  `4.0`;
- exponential upper-tail gates at `x >= 4`, `6`, `8`, and `10`;
- table support caps and approximate-log maximum smoke bounds.

The native build step is `zig build -Doptimize=ReleaseFast profilecheck-long`.
The WASI runtime step is `zig build -Doptimize=ReleaseFast wasi-profilelongcheck`.
`wasi-report` now depends on the full repro/statcheck/distcheck/profilecheck/
profiletailcheck/profilestresscheck/profilelongcheck chain.

## Native Linux Result

Command: `zig build -Doptimize=ReleaseFast profilecheck-long`

Result: passed, `profilelongcheck ok`.

Aggregate rows:

| Profile | Seeds | Lanes | Mean | Variance | Tail/support evidence |
| --- | ---: | ---: | ---: | ---: | --- |
| `VectorStandardNormalTableF32` | 8 | 8,388,608 | -0.00002687 | 0.99966339 | max_abs `4.00877237`; `|x|>=2.5` `0.01246202`, `|x|>=3.0` `0.00270879`, `|x|>=3.5` `0.00049460`, `|x|>=4.0` `0.00012398`; one-sided tails passed. |
| `VectorStandardNormalTableF64` | 8 | 8,388,608 | -0.00005080 | 0.99902498 | max_abs `4.00877259`; `|x|>=2.5` `0.01246059`, `|x|>=3.0` `0.00269783`, `|x|>=3.5` `0.00049603`, `|x|>=4.0` `0.00011671`; one-sided tails passed. |
| `VectorStandardExponentialTableF32` | 8 | 8,388,608 | 1.00022063 | 1.00161240 | max `10.39720726`; `x>=4` `0.01839852`, `x>=6` `0.00254965`, `x>=8` `0.00031030`, `x>=10` `0.00006211`. |
| `VectorStandardExponentialTableF64` | 8 | 8,388,608 | 1.00004324 | 0.99999883 | max `10.39720771`; `x>=4` `0.01834273`, `x>=6` `0.00250745`, `x>=8` `0.00030458`, `x>=10` `0.00006151`. |
| `VectorStandardExponentialApproxLogF32` | 8 | 8,388,608 | 0.99958611 | 0.99853514 | max `17.32868004`; `x>=4` `0.01828253`, `x>=6` `0.00244248`, `x>=8` `0.00033665`, `x>=10` `0.00004530`. |

All per-seed and aggregate gates passed.

## WASI Runtime Result

Command: `zig build -Doptimize=ReleaseFast wasi-profilelongcheck`

Result: passed through Node WASI. The run executed the full WASI profile chain
and ended with `profilelongcheck ok`. The profile rows matched the native
deterministic rows above.

## S4-M9 Decision

S4-M9 is closed for the current bar: accepted vector approximation profiles now
have deterministic 8Mi-lane/profile long stress gates on native Linux and WASI,
in addition to S4-M6 1Mi-lane moment/CDF gates, S4-M7 8Mi-lane fixed-seed tail
gates, S4-M8 8-seed stress gates, snapshots, reproducibility documentation, and
real-harness throughput evidence.

This does not close the long-term objective. The next bar should focus on an
additional executed non-WASI runtime/architecture target, or on a successful
exact/default-compatible dense SIMD kernel if one appears.
