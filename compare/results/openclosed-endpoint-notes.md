# OpenClosed f64 Endpoint Notes

This note captures the current evidence for exact `(0, 1]` f64 bulk sampling.
The previous throughput gap versus local Rust evidence has been closed on the
current Linux host while preserving the 53-bit endpoint grid.

## Current Baseline

Production `fillOpenClosed(f64)` uses raw `u64` words from byte-fill-capable
sources, converts the high 53 bits to the exact `(0, 1]` grid, and stores f64
values into the destination slice.

The current conversion shape is:

```zig
@mulAdd(f64, @as(f64, @floatFromInt(raw >> 11)), 1.0 / 9007199254740992.0, 1.0 / 9007199254740992.0)
```

Focused rows now exceed local Rust evidence after the exact `@mulAdd` conversion update:

- facade / FastPrng direct / ScalarPrng direct: about 792M / 792M / 793M
  samples/s on repeated 1GiB focused reruns,
- local Rust `OpenClosed01 f64`: about 778M samples/s in the same focused
  rerun.

Earlier same-host reruns with the previous multiply-after-add expression were
slower, about 653M / 631M / 649M versus Rust around 685M. Repeated
`open-closed-probe -- 134217728` runs showed 96-word and 128-word buffers tied
within noise, but the exact `@mulAdd` conversion repeatedly beat the raw
float-plus-one expression while preserving checksums.

## Rust Algorithm Audit

Local `~/Work/rand/src/distr/float.rs` uses the same multiply-based 53-bit
method for `OpenClosed01<f64>`:

1. take the high 53 random bits,
2. add one,
3. cast to float,
4. multiply by `2^-53`.

Therefore the historical gap was not an algorithm-family mismatch with local
Rust; the adopted exact `@mulAdd` conversion now exceeds the current local Rust
row on this host.

## Rejected Or Exhausted Shapes

- Scalar loop without raw-word buffering is slower.
- 64/96/128/160/192/224/256 word buffers are all within noise or worse; 128
  remains the simplest no-regression choice.
- Integer-domain `+1` before float conversion is tied with or below the adopted
  `@mulAdd` expression.
- Division by `2^53` is tied with or below the adopted multiply-add expression.
- Bitcast-based `(0, 1]` constructions regress.
- In-place conversion, raw-vector conversion, and manual unrolling regress.
- Complement-grid mappings such as `1.0 - float(raw >> 11) * 2^-53` and
  `float(2^53 - (raw >> 11)) * 2^-53` are exact endpoint-equivalent but
  regress in `open-closed-probe`.
- Skipping explicit `littleToNative(u64, raw_word)` in the local x86_64 probe
  keeps matching checksums but regresses or ties, so the portable endian-normalized
  form remains preferable.
- Narrowing the 53-bit shifted raw value to `u53` / `u54` before
  `@floatFromInt` keeps matching checksums but regresses versus the current
  `u64` shift-plus-one expression.
- Raw byte-buffer reads that skip proper word conversion can appear fast but
  produce invalid means/checksums and are rejected.

## Requirements For A Future Change

A future production candidate must:

1. Preserve the exact `(0, 1]` endpoint grid, including the ability to produce
   `1.0` and never produce `0.0`.
2. Keep checksums/means in the expected range for benchmark rows.
3. Beat the current 128-word raw-buffer path in both facade and direct-source
   focused rows, or be explicitly scoped to one source profile.
4. Be measured against local Rust `OpenClosed01 f64` in the same focused rerun.

The current exact `@mulAdd` raw-word path meets the local Linux S4-M4 bar for
this focused workload. Future changes should still satisfy the requirements
above before replacing it.
