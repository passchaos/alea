# S4-M1319 — Full `validate-all` evidence refresh

## Goal

Refresh the aggregate validation evidence after the directional, matrix, and
SIMD milestones (S4-M1309 through S4-M1318), so the roadmap and audit files are
backed by a current end-to-end run rather than older component evidence.

## Evidence

Command: `zig build validate-all --summary all`

Result:

```
Build Summary: 122/122 steps succeeded; 1739/1739 tests passed
```

Component highlights from the same run:

- native `alea-tests`: 857/857,
- native `alea-distcheck`, `alea-distcheck-libc`, and `alea-profilecheck`:
  success,
- `practrand-self-test`: success,
- crosscheck compile: wasm32-wasi-musl, aarch64-linux, riscv64-linux,
  x86_64-windows, x86_64-macos, and aarch64-macos all success,
- `test-wasi`: `alea-tests-wasm32-wasi-node` 857/857,
- `wasi-dry-run`, `wasi-self-test`, and `wasi-report`: success (the report
  chain includes repro/statcheck/distcheck/profile/profiletail/
  profilestress/profilelong through Node's WASI runtime).

The aggregate count includes the native library tests, tool tests, and the
WASI Node test binary; `zig build test --summary all` remains 876/876 for the
native test plus tool-gate composition.

## Audit refresh

The active-goal audit's non-completion list is updated to remove items that are
now implemented:

- matrix von Mises-Fisher and Kent distributions,
- SIMD von Mises/von Mises-Fisher/Watson/Bingham/Kent sampling,
- the vector/SIMD sampling families called out in older audit text.

The remaining raised bar is:

- SO(3) matrix Fisher is exact; O(3) matrix Fisher with reflections remains
  open,
- vector-directional squeeze/compaction optimizations (the vector
  Watson/Bingham paths are slower per lane than their scalar samplers),
- longer statistical validation runs and broader platform runners,
- or newly discovered core gaps against local `rand` / `rand_distr` evidence.

## Validation

- `zig build validate-all --summary all` passes 122/122 steps and 1739/1739
  tests.
- `compare/results/core-rand-coverage.md` S4-M1319 row added.
- `compare/results/active-goal-completion-audit.md` and
  `compare/results/linux-no-known-gaps-audit.md` refreshed.
