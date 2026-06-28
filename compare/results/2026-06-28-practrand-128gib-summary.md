# PractRand 128GiB Summary

Timestamp: 2026-06-28 CST

This summarizes the Stage 4 128GiB PractRand runs for the primary Linux engine
set. All runs used PractRand 0.96 `stdin64` with `-tlmin 128GB` and `-tlmax
128GB`.

| Engine | Result | Report |
| --- | --- | --- |
| `fast` / `Alea4x64` | clean pass, 320 test results | `compare/results/2026-06-28-practrand-fast-128gib.md` |
| `default` / `Xoshiro256` | one default-seed `unusual`; two alternate-seed runs clean, 320 test results each | `compare/results/2026-06-28-practrand-default-128gib.md`, `compare/results/2026-06-29-practrand-default-third-seed-128gib.md` |
| `wyhash64` | clean pass, 320 test results | `compare/results/2026-06-28-practrand-wyhash64-128gib.md` |
| `pcg64` | one default-seed `unusual`; alternate seed clean, 320 test results each | `compare/results/2026-06-28-practrand-pcg64-128gib.md` |
| `xoshiro256++` | clean pass, 320 test results | `compare/results/2026-06-28-practrand-xoshiro256plusplus-128gib.md` |
| `chacha12` | clean pass, 320 test results | `compare/results/2026-06-28-practrand-chacha12-128gib.md` |

## Interpretation

This closes the Stage 4 longer-than-64GiB external validation milestone for the
primary Linux engine set, with observations:

- `default` / `Xoshiro256` had one low-bit `unusual` in the default-seed 128GiB
  run, not reproduced by two same-length alternate-seed runs.
- `pcg64` had one low-bit birthday-spacing `unusual` in the default-seed 128GiB
  run, not reproduced by the same-length alternate-seed run.

PractRand `unusual` is not a failure by itself, but both observations should
remain visible in later longer or repeated validation stages.
