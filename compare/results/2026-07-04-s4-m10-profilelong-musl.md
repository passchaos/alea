# S4-M10 Accepted Vector Profile x86_64-linux-musl Check

Date: 2026-07-04

Purpose: close the S4-M10 bar by executing accepted vector-profile validation on
an additional non-WASI target/ABI beyond the native glibc Linux and Node WASI
runs.

## Command

```sh
zig build -Dtarget=x86_64-linux-musl -Doptimize=ReleaseFast profilecheck-long
```

Result: passed, `profilelongcheck ok`.

## Evidence Summary

The musl executable ran the same `tools/profilelongcheck.zig` 8-seed long sweep
as the native glibc and WASI runs: 1,048,576 lanes per seed and 8,388,608 lanes
per accepted vector profile.

Aggregate rows matched the deterministic glibc/WASI long-sweep evidence:

| Profile | Seeds | Lanes | Mean | Variance | Tail/support evidence |
| --- | ---: | ---: | ---: | ---: | --- |
| `VectorStandardNormalTableF32` | 8 | 8,388,608 | -0.00002687 | 0.99966339 | max_abs `4.00877237`; `|x|>=2.5` `0.01246202`, `|x|>=3.0` `0.00270879`, `|x|>=3.5` `0.00049460`, `|x|>=4.0` `0.00012398`. |
| `VectorStandardNormalTableF64` | 8 | 8,388,608 | -0.00005080 | 0.99902498 | max_abs `4.00877259`; `|x|>=2.5` `0.01246059`, `|x|>=3.0` `0.00269783`, `|x|>=3.5` `0.00049603`, `|x|>=4.0` `0.00011671`. |
| `VectorStandardExponentialTableF32` | 8 | 8,388,608 | 1.00022063 | 1.00161240 | max `10.39720726`; `x>=4` `0.01839852`, `x>=6` `0.00254965`, `x>=8` `0.00031030`, `x>=10` `0.00006211`. |
| `VectorStandardExponentialTableF64` | 8 | 8,388,608 | 1.00004324 | 0.99999883 | max `10.39720771`; `x>=4` `0.01834273`, `x>=6` `0.00250745`, `x>=8` `0.00030458`, `x>=10` `0.00006151`. |
| `VectorStandardExponentialApproxLogF32` | 8 | 8,388,608 | 0.99958611 | 0.99853514 | max `17.32868004`; `x>=4` `0.01828253`, `x>=6` `0.00244248`, `x>=8` `0.00033665`, `x>=10` `0.00004530`. |

## S4-M10 Decision

S4-M10 is closed for the current bar: accepted vector approximation profiles now
have long-sweep execution on native Linux/glibc, x86_64-linux-musl, and Node
WASI. This extends coverage beyond the previous local Linux + WASI pair and
checks the profile output mappings through a second Linux ABI/runtime.

This does not close the long-term objective. The next bar should move beyond
profile smoke/stress validation toward either:

- an exact/default-compatible dense SIMD normal/exponential kernel that wins in
  the real `vectorbench` harness;
- another architecture/runtime execution environment not currently available in
  this session; or
- a broader product audit that finds a new local `rand`/`rand_distr` core gap.
