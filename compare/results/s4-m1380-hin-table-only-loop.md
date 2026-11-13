# S4-M1380 — Table-only HIN rejection loop

## Goal

Keep the HIN binomial rejection loop free of out-of-line log-factorial calls
when the trial count is inside the comptime table range, so the loop keeps
its live values in registers instead of spilling around a possible call.

## Implementation

- Split the log-factorial helper: `binomialLogFactorialSmall` serves the
  table only and is used when the caller can prove every argument is below
  `binomial_log_factorial_len` (513); `binomialLogFactorial` keeps the
  table-or-`lnOfFactorial` general form for the setup and large trial counts.
- `binomialHinSampleFrom` takes a comptime `small` flag and selects the
  table-only or general acceptance term accordingly.
- `binomialHinDrawFrom` dispatches on `trials < binomial_log_factorial_len`
  at every call site: the top-level binomial path, the multinomial first
  conditional, and the batch HIN cache. All HIN log-factorial arguments are
  bounded by `trials`, so the condition is exact.
- The sampled stream is unchanged; only codegen changes.

## Benchmarks (ReleaseFast, `-Dcpu=native`)

Isolated direct-engine probe, five runs each:

| Call | Before | After |
| --- | --- | --- |
| `binomial(100, 1/6)` | 75.0 ns/op | 41.9 ns/op |
| `binomial(10000, 0.01)` | 59.6 ns/op | 28.4 ns/op |

Official rows (16,777,216 bytes, five runs):

| Row | Before | After | Change |
| --- | --- | --- | --- |
| `alea multinomial direct` | 8.8M samples/s | 9.2M samples/s | +4.5% |
| `alea multinomial many direct` | 11.4-11.8M samples/s | 11.6-11.7M samples/s | unchanged |
| `alea multinomial` (facade) | 8.1-8.3M samples/s | 8.1-8.3M samples/s | unchanged |
| `alea binomial large` (facade) | 28.9M samples/s | 28.7-28.8M samples/s | unchanged |

Facade rows stay flat because the facade path's codegen already avoided the
call-clobbering and remains `Rng` facade-overhead-bound; the direct-source
kernel itself is about twice as fast. Checksums are unchanged
(`545523` / `545062` / `6551812`).

## Validation

- All binomial, multinomial, negative-binomial, hypergeometric, and
  beta-binomial tests pass.
- `zig build test` passes 899/899, including `apicheck`.
- `zig build distcheck` passes; `zig build -Doptimize=ReleaseFast distcheck
  -- --long 10000000` prints `distlongcheck ok (10000000 samples)`.
- `zig fmt --check src/distributions.zig` is clean.

## Next bar

Broader platform runners (still blocked locally without QEMU/Wine/Wasmtime),
reducing `Rng` facade overhead for the facade binomial/multinomial rows, or
newly discovered core gaps.
