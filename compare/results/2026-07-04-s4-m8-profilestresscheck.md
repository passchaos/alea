# S4-M8 Accepted Vector Profile Multi-Seed Stress Check

Date: 2026-07-04

Purpose: extend accepted vector-profile validation beyond fixed-seed smoke and
tail checks with deterministic multi-seed stress evidence on native Linux and
WASI.

## Tool Added

`tools/profilestresscheck.zig` samples each accepted throughput-first vector
profile across 8 deterministic seeds with 262,144 lanes per seed (2,097,152
lanes per profile total). It checks:

- per-seed mean and variance windows;
- aggregate mean and variance windows;
- aggregate CDF gates for standard normal and standard exponential;
- aggregate normal two-sided and one-sided tail gates;
- aggregate exponential upper-tail gates;
- expected table support caps and approximate-log maximum smoke bounds.

The native build step is:

```sh
zig build -Doptimize=ReleaseFast profilecheck-stress
```

The WASI runtime step is:

```sh
zig build -Doptimize=ReleaseFast wasi-profilestresscheck
```

`wasi-report` now depends on the full repro/statcheck/distcheck/profilecheck/
profiletailcheck/profilestresscheck chain.

## Native Linux Result

Command: `zig build -Doptimize=ReleaseFast profilecheck-stress`

Result: passed, `profilestresscheck ok`.

Aggregate rows:

| Profile | Seeds | Lanes | Mean | Variance | Tail/support evidence |
| --- | ---: | ---: | ---: | ---: | --- |
| `VectorStandardNormalTableF32` | 8 | 2,097,152 | 0.00009996 | 1.00047589 | max_abs `4.00877237`; `|x|>=2.5` `0.01256609`, `|x|>=3.0` `0.00272799`, `|x|>=3.5` `0.00050879`, `|x|>=4.0` `0.00013018`; one-sided tail balance passed. |
| `VectorStandardNormalTableF64` | 8 | 2,097,152 | -0.00028033 | 0.99971408 | max_abs `4.00877259`; `|x|>=2.5` `0.01243210`, `|x|>=3.0` `0.00267744`, `|x|>=3.5` `0.00049019`, `|x|>=4.0` `0.00012636`; one-sided tail balance passed. |
| `VectorStandardExponentialTableF32` | 8 | 2,097,152 | 0.99855265 | 0.99930547 | max `10.39720726`; `x>=4` `0.01826811`, `x>=6` `0.00250626`, `x>=8` `0.00030136`, `x>=10` `0.00006819`. |
| `VectorStandardExponentialTableF64` | 8 | 2,097,152 | 1.00047430 | 0.99991948 | max `10.39720771`; `x>=4` `0.01835394`, `x>=6` `0.00245762`, `x>=8` `0.00030470`, `x>=10` `0.00005960`. |
| `VectorStandardExponentialApproxLogF32` | 8 | 2,097,152 | 1.00029947 | 1.00103512 | max `14.76373100`; `x>=4` `0.01843548`, `x>=6` `0.00246382`, `x>=8` `0.00033140`, `x>=10` `0.00004244`. |

All per-seed mean/variance gates and aggregate CDF/tail gates passed.

## WASI Runtime Result

Command: `zig build -Doptimize=ReleaseFast wasi-profilestresscheck`

Result: passed through Node WASI. The run executed the full WASI chain and ended
with `profilestresscheck ok`. The profile rows matched the native deterministic
rows above.

## S4-M8 Decision

S4-M8 is closed for the current bar: accepted vector approximation profiles now
have deterministic multi-seed stress gates on native Linux and WASI, in addition
to S4-M6 1Mi-lane moment/CDF gates, S4-M7 8Mi-lane tail gates, snapshots,
reproducibility documentation, and real-harness throughput evidence.

This does not close the long-term objective. The next bar should move beyond
fixed deterministic stress runs: add an executed non-WASI runtime target, longer
multi-seed/tail sweeps if feasible, or replace the watch with a successful
exact/default-compatible dense SIMD kernel.
