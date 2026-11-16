# S4-M1735 Wrapped Normal Vector Wrap Test And Validate-All Refresh

Date: 2026-11-16

## Test

Added `WrappedNormal vector wrapping covers out-of-range lanes`:

- `sigma = 3` puts many lanes outside `(-π, π]` but inside `3π`, exercising
  the branchless two-pass vector wrap.
- `sigma = 50` produces raw draws beyond `3π`, exercising the modulo wrap.

Each case samples 64 `@Vector(4, f64)` values and checks that every lane is
finite and lands in `(-π, π]`.

## Validation

- `zig build test distcheck statcheck --summary all`: 39/39 steps and 985/985
  tests (native `alea-tests` 962/962).
- `zig build validate-all --summary all`: 124/124 steps and 1951/1951 tests,
  including native `alea-tests` 962/962, WASI Node tests 962/962, all six
  crosscheck targets, and the chained WASI report.
- The 1e9 evidence is `compare/results/s4-m1734-1e9-long-run-refresh.md`; the
  added test is test-only and does not change the sampler behavior.
