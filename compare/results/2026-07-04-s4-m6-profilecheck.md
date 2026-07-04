# S4-M6 Accepted Vector Profile Check

Date: 2026-07-04

Purpose: harden the S4-M5 approximation-profile policy beyond the initial local
Linux smoke evidence by adding a longer deterministic distribution-quality gate
and executing it on a second runtime target.

## Tool Added

`tools/profilecheck.zig` samples each accepted throughput-first vector profile for
1,048,576 lanes and checks:

- mean and variance windows;
- fixed CDF smoke points for standard normal: `-3`, `-2`, `-1`, `0`, `1`, `2`,
  `3`;
- fixed CDF smoke points for standard exponential: `0.1`, `0.25`, `0.5`, `1`,
  `2`, `4`, `6`;
- finite output and observed min/max reporting.

The new `zig build profilecheck` step is included in `zig build validate`. The
WASI runner now includes `wasi-profilecheck`, and `wasi-report` depends on it.

## Native Linux Result

Command:

```sh
zig build -Doptimize=ReleaseFast profilecheck
```

Result: passed, `profilecheck ok`.

Representative checked rows:

| Profile | Lanes | Mean | Variance | Min | Max |
| --- | ---: | ---: | ---: | ---: | ---: |
| `VectorStandardNormalTableF32` | 1,048,576 | 0.00059775 | 0.99906441 | -4.00877237 | 4.00877237 |
| `VectorStandardNormalTableF64` | 1,048,576 | -0.00048099 | 1.00220897 | -4.00877259 | 4.00877259 |
| `VectorStandardExponentialTableF32` | 1,048,576 | 0.99936433 | 1.00091987 | 0.00003052 | 10.39720726 |
| `VectorStandardExponentialTableF64` | 1,048,576 | 1.00124960 | 1.00219665 | 0.00003052 | 10.39720771 |
| `VectorStandardExponentialApproxLogF32` | 1,048,576 | 0.99928951 | 0.99542508 | 0.00000119 | 15.71924114 |

All configured normal and exponential CDF gates passed within tolerance.

## WASI Runtime Result

Command:

```sh
zig build -Doptimize=ReleaseFast wasi-profilecheck
```

Result: passed through Node WASI. Because the `wasi-profilecheck` step depends on
`wasi-distcheck`, the run also emitted `repro`, `statcheck ok`, and `distcheck
ok` before the same profile rows and final `profilecheck ok`.

The WASI profile rows matched the native deterministic profile rows listed above,
which gives a second-target execution check for the accepted approximation
profiles' output mapping and distribution smoke gates.

## Cross-Target Compile Finding

While adding `profilecheck`, `zig build crosscheck` exposed an existing
unsupported-target compile issue in the libc/libmvec log-normal opt-ins:
`std.DynLib` methods were referenced on targets where Zig's dynamic-library
backend is an unsupported stub. The implementation now uses an internal fallback
handle type plus comptime init guards so unsupported targets compile and the
opt-ins return their documented unavailable errors.

Validation after the fix:

```sh
zig build test --summary all
zig build -Doptimize=ReleaseFast validate
zig build crosscheck
zig build -Doptimize=ReleaseFast wasi-profilecheck
```

All passed. `zig build validate` now includes `profilecheck`.

## S4-M6 Decision

S4-M6 is closed for the current bar: accepted vector approximation profiles now
have longer deterministic distribution-quality gates and a second executed target
(WASI) in addition to the previous local Linux vectorbench, distcheck, unit
snapshot, and reproducibility-matrix evidence.

This does not close the long-term objective. The next bar should extend beyond
1Mi-lane smoke checks toward longer/adversarial tail validation, more executed
non-WASI targets, or an exact/default-compatible dense SIMD kernel if a new
candidate appears.
