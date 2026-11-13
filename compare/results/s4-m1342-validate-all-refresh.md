# S4-M1342 — Validate-all refresh after the continuous diagnostics batch

## Goal

Refresh the full aggregate validation evidence after S4-M1337 through S4-M1341,
which added Bernoulli, core continuous, advanced continuous,
ExGaussian/inverse-Gaussian, and skew-normal/PERT CDF and quantile diagnostics.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1779/1779 tests passed
```

Component highlights:

- native `alea-tests`: 876/876,
- WASI Node `alea-tests-wasm32-wasi-node`: 876/876,
- `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`: success
  (2/2 tool tests each),
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success.

`zig build test` independently passes 895/895 (876 library tests plus 19
doc/tool-gate tests). The native and WASI binaries exercise every symbol added
since the S4-M1336 refresh, including `bernoulliCdf`/`bernoulliQuantile`,
`exponentialCdf`, `logNormalCdf`, `halfNormalCdf`, `chiCdf`, `erlangCdf`,
`maxwellCdf`, `betaPrimeCdf`, `logLogisticCdf`, `inverseGammaCdf`,
`nakagamiCdf`, `exGaussianCdf`, `inverseGaussianCdf`, `skewNormalCdf`,
`pertCdf`, and their quantile counterparts and sampler methods.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1779/1779
  tests.
- `zig build -Doptimize=ReleaseFast distcheck -- --long 10000000` prints
  `distlongcheck ok (10000000 samples)`.
- `compare/results/core-rand-coverage.md` S4-M1342 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
Rice/Hoyt diagnostics (Marcum Q), further performance work, or newly discovered
core gaps.
